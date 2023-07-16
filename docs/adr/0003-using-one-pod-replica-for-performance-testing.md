# 3. using one pod replica for performance testing

Date: 2023-07-16

## Status

Accepted

## Context

The issue motivating this decision, and any context that influences or constrains the decision.
We will only use one pod replica for our load testing setup: see 
`deploy/kubernetes/ci-performance/kustomization.yaml:10`

## Decision

We're dropping the number of service pod replicas two one for the `ci-performance` environment.  This is because
- We get a truer test of the application performance and not Kubernete's ability round-robin load between `n` number of pods
- Observability, Logging and debugging is simplified during performance testing as you only have one set of telemetry to look at as opposed to looking multitple

## Consequences

We will get to see application specific bottlenecks more easily, but we don't get to see how the application performs with a more production like setup spread over `n` number of nodes. To get that data we can spin up a pre-production performance environment which mirrors a production topology.
