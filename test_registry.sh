#!/usr/bin/env bash
set -euo pipefail

reg_host=localhost
reg_port='5000'
reg_url=$reg_host:$reg_port

# Push http-echo to local registry
echo
echo "@ Pull, tag and push http-echo image"
HTTP_ECHO_VERSION=0.2.3
docker pull hashicorp/http-echo:$HTTP_ECHO_VERSION
docker tag hashicorp/http-echo:$HTTP_ECHO_VERSION $reg_url/http-echo:$HTTP_ECHO_VERSION
docker push $reg_url/http-echo:$HTTP_ECHO_VERSION

# Deploy http-echo from local registry
echo
echo "$ kubectl apply -f -"
APP=echo-app
cat <<EOF | kubectl apply -f -
kind: Pod
apiVersion: v1
metadata:
  name: $APP
  labels:
    app: foo
spec:
  containers:
  - name: $APP
    image: $reg_url/http-echo:$HTTP_ECHO_VERSION
    args:
    - "-text=echo"
EOF

# Wait until pod is ready
echo
echo "@ Waiting for pods are ready to process requests"
kubectl wait \
  --for=condition=ready \
  pod $APP \
  --timeout=90s

# Delete POD
echo
echo "$ kubectl delete pod $APP"
kubectl delete pod $APP
