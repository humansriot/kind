#!/usr/bin/env bash
set -euo pipefail

wait_until_curl() {
  request=$1

  printf "%s: " "$request"
  until curl --output /dev/null --silent --head --fail "$request"; do
    printf '.'
    sleep 1
  done
  echo "OK"
}

# Apply example-ingress
echo
echo '$ kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml'
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml

# Wait until pods are ready to process requests
echo
echo "Waiting for pods are ready to process requests"
kubectl wait \
  --for=condition=ready pod \
  --selector=app=foo \
  --timeout=90s
kubectl wait \
  --for=condition=ready pod \
  --selector=app=bar \
  --timeout=90s

# Test ingress
echo
echo '$ kubectl describe ingress example-ingress'
kubectl describe ingress example-ingress
echo
wait_until_curl http://localhost/foo
wait_until_curl http://localhost/bar

# Delete example-ingress
echo
echo '$ kubectl delete -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml'
kubectl delete -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml
