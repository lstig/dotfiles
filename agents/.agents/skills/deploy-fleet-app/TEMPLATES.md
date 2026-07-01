# Deploy method templates

Both patterns live under `k8s-apps/components/<category>/{base,prod}/<app>/`. Pick one branch — don't mix.

## Helm chart (HelmRepository)

`base/<app>/repo.yaml`:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: <app>
  namespace: <app>
spec:
  interval: 12h
  url: https://<upstream-chart-repo>
```

`base/<app>/release.yaml`:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: <app>
  namespace: <app>
spec:
  serviceAccountName: flux
  interval: 1h
  chart:
    spec:
      version: "< X.0.0"       # semver ceiling, not a pin
      chart: <chart-name>
      sourceRef:
        kind: HelmRepository
        name: <app>
      interval: 12h
  install:
    crds: Create
    timeout: 4m
  upgrade:
    crds: CreateReplace
    timeout: 4m
  valuesFrom:
    - name: <app>-defaults
      kind: ConfigMap
      valuesKey: values.yaml
```

`base/<app>/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: <app>
configurations:
  - configuration.yaml
labels:
  - pairs:
      app.kubernetes.io/name: <app>
      toolkit.fluxcd.io/tenant: apps
resources:
  - namespace.yaml
  - release.yaml
  - repo.yaml
configMapGenerator:
  - name: <app>-defaults
    files:
      - values.yaml   # default Helm values for this chart
```

`base/<app>/configuration.yaml` (lets kustomize follow the generated ConfigMap's hashed name into the HelmRelease):

```yaml
---
nameReference:
  - kind: ConfigMap
    fieldSpecs:
      - kind: HelmRelease
        path: spec/valuesFrom/name
```

### OCI variant

If the chart is published as an OCI artifact instead of a classic Helm repo, replace `repo.yaml`'s `HelmRepository` with:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: OCIRepository
metadata:
  name: <app>
spec:
  interval: 12h
  url: oci://<registry>/<path>
  ref:
    semver: "< X.0.0"
  layerSelector:
    mediaType: application/vnd.cncf.helm.chart.content.v1.tar+gzip
```

and in `release.yaml` swap `spec.chart` for:

```yaml
spec:
  chartRef:
    kind: OCIRepository
    name: <app>
```

### Prod overlay (Helm)

`prod/<app>/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base/<app>
  - routes.yaml            # only if externally exposed
patches:
  - path: helmrelease.patch.yaml   # only if prod needs values/postRenderers overrides
```

Use `helmrelease.patch.yaml` (a partial `HelmRelease` with matching `metadata.name`/`namespace`) for prod-only overrides like `postRenderers` patches. Add a prod-specific values ConfigMap the same way `base` does if defaults need overriding per environment.

## Raw Kustomize manifests

`base/<app>/namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <app>
```

`base/<app>/deployment.yaml`, `service.yaml`, `storage.yaml` — standard manifests for the app.

`base/<app>/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: <app>
images:
  - name: <upstream/image>
    newName: <registry>/<image>   # {"$imagepolicy": "flux-system:<category>-<app>-<image>:name"}
    newTag: "<current-tag>"       # {"$imagepolicy": "flux-system:<category>-<app>-<image>:tag"}
resources:
  - deployment.yaml
  - namespace.yaml
  - service.yaml
  - storage.yaml
```

The `$imagepolicy` marker comments must sit on the exact line holding the field they update — the image-automation controller edits that line in place.

`update/<category>-<app>.yaml` in k8s-apps (register in `update/kustomization.yaml`):

```yaml
---
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: <category>-<app>-<image>
spec:
  image: "<upstream/image>"
  interval: 12h
  provider: generic
---
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: <category>-<app>-<image>
spec:
  imageRepositoryRef:
    name: <category>-<app>-<image>
  policy:
    semver:
      range: "< X.0.0"
```

### Prod overlay (Kustomize)

`prod/<app>/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base/<app>
  - routes.yaml       # only if externally exposed
  - media.yaml         # only if it needs extra prod-only storage (e.g. SMB-backed PV/PVC)
patches:
  - path: deployment.patch.yaml   # only if prod needs container/volume overrides
```

## Shared: external exposure

`prod/<app>/routes.yaml` (only for apps reachable from outside the cluster):

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: <app>
  namespace: <app>
spec:
  parentRefs:
    - name: app
      namespace: envoy-gateway-system
  hostnames:
    - "<app>.app.stignet.com"
  rules:
    - backendRefs:
        - group: ""
          kind: Service
          name: <app>-service
          port: <port>
          weight: 1
      matches:
        - path:
            type: PathPrefix
            value: /
```
