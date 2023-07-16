# K8s deployments using Kustomize

Using [Kustomize](https://kustomize.io/) to merge values for different kubernetes environments.

## Example

```bash

(ENVIRONMENT="ci-performance" cd deploy/kubernetes &&
    kustomize build "${ENVIRONMENT}" | \
    kubectl apply -f -)
```
