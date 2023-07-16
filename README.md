# k8s Kind Load Testing
A sample load testing setup for k8s hosted services.

![dall-e: place a shipping container on top another container, pixel art](logo.png)

## Getting started

### Tooling

Developed on a Linux x86 machine.

Tested working with:
- kind `v0.20.0`
- kubectl `v1.26.0` (contains `kustomize`)

### Commands

#### Deployment and testing in Kind

```bash

# create kind cluster, it should automatically switch your kubectl context over
# ~1m29s
kind create cluster --name kind-ci-load-testing

# test cluster
kubectl get nodes

# deploy application stack
(ENVIRONMENT="ci-performance"
    kubectl kustomize "deploy/kubernetes/${ENVIRONMENT}" | \
    kubectl apply -f -)

# check on the deployment
kubectl -n k8s-kind-load-testing get all

# test service one with port-forwarding into the svc
kubectl -n k8s-kind-load-testing \
    port-forward svc/service-service-one 8080:5678
curl localhost:8080

# test svc

```

## Things I learnt

- Using `kind` inside of a Gitlab C runner
- Surfacing CI step results into a PR

### Things that bit me in the behind

- The version of `http-echo` published on [Docker hub](https://hub.docker.com/r/hashicorp/http-echo) is way behind the version in the [Github repo](https://github.com/hashicorp/http-echo). The code in the repo allows for the setting of the `ECHO_TEXT` env var and not the Docker hub mandatory `-text` option


## Todo

- [x] setup application stack in k8s
    - [x] setup Kustomize templates
    - [x] create namespace
    - [x] create deployment for http-echo
    - [x] setup service
    - [x] test 
    - [ ] replicate for second service
    - [ ] setup ingress to route between two deployments
- [ ] generate load
    - [ ] hammer with vegeta - simple
- [ ] write Github actions setup to run all this in Github CI
- [ ] get Vegeta output into PR

### Stretch goals

- [ ] Setup some observability
    - [ ] deploy prom+grafana into cluster
    - [ ] surface container stats using `cadvisor`
    - [ ] implement nginx sidecar to surface Prometheus telemetry
    - [ ] surface some APM (application runtime telemetry)
    - [ ] surface cluster metrics: cpu/ram/network/disk
    - [ ] surface telemetry into PRs
- [ ] Write a more advanced load testing setup in k3s
- [ ] Use Helm over Kustomize