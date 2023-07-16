# 6. using built in github actions for kind

Date: 2023-07-16

## Status

Accepted

## Context

Github has two built in actions that implement a kind cluster for you.

## Decision

We're going to use a ready made kind action [from Hashicorp](https://github.com/marketplace/actions/kind-cluster) as opposed to installing and configuring kind on a "bare metal" runner.

## Consequences

This should hopefully speed up delivery at the expense of possibly losing some customisation.
