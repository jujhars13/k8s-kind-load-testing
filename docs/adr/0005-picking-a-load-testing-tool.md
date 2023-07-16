# 5. picking a load testing tool

Date: 2023-07-16

## Status

Accepted

## Context

We need to consider which load testing tool to use

## Decision

We're going to use [Vegeta](https://github.com/tsenart/vegeta) as it is robust, simple and fast.  `Jujhars13` already has a tried and tested [docker hub image for it](https://hub.docker.com/r/jujhars13/vegeta).  It also gives quite nice output `Latencies     [min, mean, 50, 90, 95, 99, max]` that quickly tick the box for us

Other tools worth considering:
- Gatling (popular in market)
- k3s (allow for more complex load testing scenarios)
- Apache bench (very simple and trusted tool)
- many more tools in this space,both hosted and SaaS enabled...

## Consequences

Vegeta is suited to simple "sledgehammer" type load testing, which is all we require at this stage.
We will **NOT** get much randomisation of data initially using default params and that will have to be injected in
For future implementations we can consider using a more nuanced tool like k3s.
