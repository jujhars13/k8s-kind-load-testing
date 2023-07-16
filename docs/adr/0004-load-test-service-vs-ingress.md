# 4. load test service vs ingress

Date: 2023-07-16

## Status

Accepted

## Context

1. Do we wish to test the nginx ingress + k8s service or just the service alone, or both?
2. Do we want to test just one pod or multiple pods?

```
                        1. Test just the services?
                           ─────────────────────┐
                          │                     │
                          │                     │
                          │                     │
                          │                     │
┌─────────────────────────┼─────────────────────┼─────────────────┐
│                         │                     │                 │
│                         │                     │                 │
│        ns: k8s-kind-load│testing              │                 │
│        ┌────────────────┼─────────────────────┼──────────┐      │
│        │                │                     │          │      │
│        │    ┌───────────▼───┐       ┌─────────▼──────┐   │      │
│        │    │               │       │                │   │      │
│        │    │  k8s svc one  │       │   k8s svc two  │   │      │
│        │    │               │       │                │   │      │
│        │    │               │       │                │   │      │
│        │    └───────────────┘       └────────────────┘   │      │
│        │                                                 │      │
│        │                                                 │      │
│        │                                                 │      │
│        │     ┌──────────────┐       ┌────────────────┐   │      │
│        │     │   foo (one)  │       │    bar (two)   │   │      │
│        │     │              │       │    pod(s)      │   │      │
│        │     │   pod(s)     │       │                │   │      │
│        │     │              │       │                │   │      │
│        │     └──────────────┘       └────────────────┘   │      │
│        │                                                 │      │
│        └─────────────────────────────────────────────────┘      │
│                                                                 │
│         ns: nginx-ingress                                       │
│       ┌──────────────────────────────────┐                      │
│       │                                  │                      │
│       │  ┌─────────────────┐             │                      │
│       │  │    nginx (pods) │             │                      │
│       │  │                 │             │                      │
│       │  └────────────▲────┘             │                      │
│       │               │                  │                      │
│       └───────────────┼──────────────────┘                      │
│                       │                                         │
│                       │                                         │
└───────────────────────┼─────────────────────────────────────────┘
                        │
                        │
                        │
                        │
                        │
                        │
                        │
                        │
                        │
                 ───────┘
    2. Test ingress + services?
```

## Decision

### 1. Just the service
We're going to load test the service to see what it's capabale of and testing the ingress performance is out of scope.
    - We want to see how our service performs, especially as we change it
    - We're not interested in the performance of the nginx ingress

Also, we can test the service by either port-forwarding directly into it, or deploying a load testing container directly into the namespace to hammer the workload.

By using port-forwarding we can easier access the results of the load testing (as they'll run locally).  Running inside the kubernetes workspace and grabbing the results will be more work (but probably more representatative of actual service performance as it will not be bottlenecked by port-forwarding)

In addition we'll be running the kubernetes cluster and the load testing in the same thread-pool on a multi-tennanted Github CI runner, to get a more accurate representation we should ideally be running more dedicated tennants and have the kubernetes cluster and the load testing run in separate compute instances/environments.  We'll probably get wildly inconsistent results or hit the compute ceiling before we ascertain any real detail.

### 2. Just one pod

We want to know how our service performs as we make changes to it.  It will be easier to see how the service performs if there is only one copy of it as opposed to horizontally scaling it over to two copies which can radically alter service behaviour.

## Consequences

- Surfacing the test results will be easier
- We'll not be taking nginx ingress performance into account

Test results will be indicative as:
    - We might get bottlenecked by port-forwarding performance
    - Running this on a Github CI runner means we'll be sharing a single pool of threads inside the runner - we'll probably max out CPU before we manage to find the limits of the surface.
