# k8s-kind-load-testing
A sample load testing setup for k8s hosted services

## Getting started

### Tooling

Developed on a Linux x86 machine

Tested working with: 
- kind `v0.20.0`
- kubectl `v1.26.0`

### Commands

```bash

```


## Todo

- [ ] Setup kind and document commands
- [ ] setup application stack in k8s
    - [ ] setup Kustomize templates
    - [ ] create namespace
    - [ ] create 2x different deployment for http-echo
    - [ ] setup services
    - [ ] setup ingress to route between two deployments
- [ ] generate load
    - [ ] hammer with vegeta - simple
- [ ] write Github actions setup to run all this in Github CI
- [ ] get Vegeta output into PR

### Stretch goals

- [ ] Write a load testing setup in k3s
- [ ] Setup some observability
    - [ ] surface cluster metrics
    - [ ] surface some APM (application runtime telemetry)