# Kind Load Testing

[![pull-request](https://github.com/jujhars13/k8s-kind-load-testing/actions/workflows/pull-request.yaml/badge.svg)](https://github.com/jujhars13/k8s-kind-load-testing/actions/workflows/pull-request.yaml)

A sample load testing setup for k8s hosted services leveraging Github CI actions.

![Dall-e: place a shipping container on top another container, pixel art](logo.png)


## Things I learnt

- Using `kind` inside of a Gitlab CI runner
- Surfacing CI step results into a PR

### Things that bit me in the behind

- The version of `http-echo` published on [Docker hub](https://hub.docker.com/r/hashicorp/http-echo) is way behind the version in the [Github repo](https://github.com/hashicorp/http-echo). The code in the repo allows for the setting of the `ECHO_TEXT` env var and not the Docker hub mandatory `-text` cli option
- Struggled with Nginx admission webhook for kind, apparently it's an issue with the tolerations of the Nginx config for the latest versions of kind - had to write a manifest patch for Nginx ingress to get around issue


## Development

### ADRs - Architectural Decision Records

[Architectural Decision Records](https://www.thoughtworks.com/radar/techniques/lightweight-architecture-decision-records) are stored in `doc/adr` and we're using [adr-tools](https://github.com/npryce/adr-tools) to help generate them.
We use ADRs as an immutable, collaborative document to record our technical decision making.

### Tooling

Developed on a Linux `x86/64` machine.

Tested working with:
- kind `v0.20.0`
- kubectl `v1.26.0` and utilizing `kustomize` for k8s manifest templates
- [Vegeta](https://github.com/tsenart/vegeta) `v12.9` for simple load testing

### Coding Standards

- Bash - [shellcheck](https://www.shellcheck.net/)

### Deployment and testing in Kind

```bash
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

# test cluster
kubectl get nodes

# deploy nginx ingress component (kind specific)
# requires patch to add toleration to get working
# @see https://github.com/kubernetes/ingress-nginx/issues/8605
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml --output /tmp/ingress-nginx-deploy.yaml
patch -u /tmp/ingress-nginx-deploy.yaml -i nginx-ingress-toleration.patch
kubectl apply -f /tmp/ingress-nginx-deploy.yaml

# wait till ingress is ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# deploy application stack
(ENVIRONMENT="ci-performance"
    kubectl kustomize "deploy/kubernetes/${ENVIRONMENT}" | \
    kubectl apply -f -)

# wait till appplication deploys
kubectl wait --namespace k8s-kind-load-testing \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=app-one \
  --timeout=120s

# check on the deployment
kubectl -n k8s-kind-load-testing get all

# test service one with port-forwarding into the svc
kubectl -n k8s-kind-load-testing \
    port-forward svc/service-app-one 8080:5678
curl localhost:8080

# test service two svc
kubectl -n k8s-kind-load-testing \
    port-forward svc/service-app-two 8081:5679
curl localhost:8081

# test ingress, setup local dns overrides first
echo "
# k8s kind load testing
127.0.0.1 foo.localhost
127.0.0.1 bar.localhost
" | sudo tee -a /etc/hosts

curl -i http://foo.localhost
curl -i http://bar.localhost

# blow away cluster
kind delete cluster --name kind-ci-load-testing
```

## Todo

- [x] setup ADR directory
- [x] setup application stack in k8s
    - [x] setup Kustomize templates
    - [x] create namespace
    - [x] create deployment for http-echo
    - [x] setup service
    - [x] test 
    - [x] replicate for second service (`1:54:00`)
    - [x] setup ingress to route between two deployments (`3:32:40`)
- [x] generate load
    - [x] hammer with vegeta - simple (`4:50:40`)
- [x] write Github actions setup to run all this in Github CI (`5:20:22`)
- [x] get Vegeta output into PR (`6:20:08`)

### Stretch goals

- [ ] split CI into separate jobs for more modularity and better readability
  - [ ] move linting step to push event
  - [ ] limit load testing to pull request only
- [ ] Setup some observability
    - [ ] deploy prom+grafana into cluster
    - [ ] surface container stats using `cadvisor`
    - [ ] implement nginx sidecar to surface Prometheus telemetry
    - [ ] surface some APM (application runtime telemetry)
    - [ ] surface cluster metrics: cpu/ram/network/disk
    - [ ] surface telemetry into PRs
- [ ] Generate some nice gnuplots of load testing histograms
- [ ] Write a more advanced load testing setup in k3s
- [ ] Use Helm over Kustomize