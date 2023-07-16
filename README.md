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

```

## Things I learnt

- Using `kind` inside of Gitlab CI
- surfacing CI results into a PR

## Todo

- [ ] setup application stack in k8s
    - [ ] setup Kustomize templates
    - [ ] create namespace
    - [ ] create deployment for http-echo
    - [ ] setup services
    - [ ] test 
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