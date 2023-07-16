#!/bin/bash
# Create a k8s kind cluster
# install nginx ingress and check to see if everything looks good
# USAGE: ./crete-kind-cluster.sh

if [[ ! $(which kind) ]]; then
  # shellcheck disable=SC2188,SC2210
  >2& echo "kind binary not found"
  exit 4
fi

echo "Using $(kind --version)"

# create kind cluster, it should automatically switch your kubectl context over
# additional cluster config required to get nginx ingress working
# @see https://kind.sigs.k8s.io/docs/user/ingress/
# @see https://github.com/kubernetes/ingress-nginx/issues/8605
# ~1m29s
cat <<EOF | kind create --name kind-ci-load-testing cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF

echo "Deploying nginx ingress"
# deploy nginx ingress component (kind specific)
# requires patch to add toleration to get working
# @see https://github.com/kubernetes/ingress-nginx/issues/8605
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml --output /tmp/ingress-nginx-deploy.yaml
patch -u /tmp/ingress-nginx-deploy.yaml -i nginx-ingress-toleration.patch
kubectl apply -f /tmp/ingress-nginx-deploy.yaml

echo "Wait till ingress is ready"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

kubectl --ns ingress-nginx get all