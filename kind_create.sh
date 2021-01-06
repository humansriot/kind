#!/usr/bin/env bash
set -euo pipefail

KIND_SCRIPT_PATH=$(dirname "$0")
KIND_SCRIPT_PATH=$(cd "$KIND_SCRIPT_PATH" && pwd)
KIND_CLUSTER_CONFIG=${1:-$KIND_SCRIPT_PATH/cluster.yaml}
KIND_CLUSTER_NAME="${2:-kind}"

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
cat "$KIND_CLUSTER_CONFIG" > "$TMP"
cat >> "$TMP" <<EOF
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_host}:${reg_port}"]
EOF
cat "$TMP"
kind create cluster --name="$KIND_CLUSTER_NAME" --config="$TMP"
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
    host: "${reg_host}:${reg_port}"
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
