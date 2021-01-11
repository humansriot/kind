#!/usr/bin/env bash
set -euo pipefail

function follow_links() {
  file="$1"
  while [ -h "$file" ]; do
    # On Mac OS, readlink -f doesn't work.
    file="$(readlink "$file")"
  done
  echo "$file"
}

HELPER_NAME=$(basename "$0")
HELPER_PATH=$(dirname "$(follow_links "$0")")

function check_command() {
  local name
  local command
  name=$1
  command=$2

  if $command &> /dev/null; then
    echo
    echo "$ $command"
    $command
  else
    echo "$name is missing"
  fi
}

function doctor() {
  check_command docker "docker --version"
  check_command kubectl "kubectl version"
  check_command kind "kind version"
  check_command kind_helper "kind_helper version"
}

function create_cluster() {
  local cluster_config
  local cluster_name
  cluster_config=$1
  cluster_name=$2

  # Create registry container unless it already exists
  reg_name='kind-registry'
  reg_host=${reg_name}
  reg_port='5000'
  running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
  if [ "${running}" != 'true' ]; then
    docker run \
      -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" \
      registry:2
  fi

  # Create a cluster with the local registry enabled in containerd
  TMP=$(mktemp)
  cat "$cluster_config" > "$TMP"
  cat >> "$TMP" <<EOF
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_host}:${reg_port}"]
EOF
  cat "$TMP"
  kind create cluster --name="$cluster_name" --config="$TMP"
  rm "$TMP"

  # Connect the registry to the cluster network
  # (the network may already be connected)
  docker network connect "kind" "${reg_name}" || true

  # Document the local registry
  # https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

  # Deploy Ingress NGINX controller
  NGINX_INGRESS_CONTROLLER_VERSION=0.43.0
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v${NGINX_INGRESS_CONTROLLER_VERSION}/deploy/static/provider/kind/deploy.yaml
  kubectl wait --namespace ingress-nginx \
    --for condition=available \
    deployment ingress-nginx-controller \
    --timeout=90s
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready \
    pod --selector=app.kubernetes.io/component=controller \
    --timeout=90s
}

function help() {
  echo "${HELPER_NAME}: ${VERSION} on ${UNAME}"
  echo ""
  echo "Usage: ${HELPER_NAME} <command>"
  echo ""
  echo "Available commands:"
  echo "  create [<config>] [<name>]    Create cluster (optional: <config> file, <name> cluster name)"
  echo "  test                          Test cluster"
  echo ""
  echo "  changelog     Show changelog"
  echo "  version       Update ${HELPER_NAME} command"
  echo "  update        Update ${HELPER_NAME} command"
}

UNAME=$(uname -s)
CMD=${1:-""}
MAKE="make -C $HELPER_PATH --no-print-directory"
VERSION=$($MAKE version)

case ${CMD} in
  "changelog")
    $MAKE changelog
    ;;
  "version")
    $MAKE version
    ;;
  "update")
    $MAKE update
    ;;
  "doctor")
    doctor
    ;;
  "create")
    shift
    create_cluster "${1:-$HELPER_PATH/cluster.yaml}" "${2:-kind}"
    ;;
  "test")
    "$HELPER_PATH"/test_ingress.sh
    "$HELPER_PATH"/test_registry.sh
    ;;
  *)
    help
    ;;
esac
