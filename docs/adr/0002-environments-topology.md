# 2. environments topology

Date: 2023-07-16

## Status

Accepted

## Context


We are going to use the following environment setup:

env | reason
- | - 
development | local development, lots of unit testing and other automation
team-staging | a team based staging environment for teams to test out their changes against other services.  Lots of automated testing with a little bit of exploratory testing
ci-performance | performance testing during CI
staging | a centralised staging environment to automate and exploratory test all incoming changes against each other
pre-production | performance and load testing of our applications and environment as close to production as possible with some light touch exploratory testing
production | Production


## Consequences

It is hoped this multiple environment setup will make it easier to find defects and shorten feedback loops without creating too many layers that can also be detrimental.
