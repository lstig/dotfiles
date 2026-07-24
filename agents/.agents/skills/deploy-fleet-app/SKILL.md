---
name: deploy-fleet-app
description: Scaffold and wire a new off-the-shelf app into the k8s-fleet GitOps repos and verify Flux reconciles it.
disable-model-invocation: true
metadata:
  internal: true
---

Coordinates a new app across the three Flux repos that make up the fleet: mostly edits **k8s-apps**, occasionally **k8s-fleet** or **k8s-infra**. See TEMPLATES.md for the exact files each deploy method needs.

## Repo map

| Repo | Path | Role | Touch it when |
|---|---|---|---|
| k8s-fleet | `~/Code/infrastructure/k8s-fleet` | Cluster bootstrap; one Flux Kustomization per category under `tenants/{apps,infra}/components/` | A brand-new *category* or tenant is needed (rare) |
| k8s-apps | `~/Code/infrastructure/k8s-apps` | "apps" tenant, `GitRepository/flux-apps` | Almost every deploy — this is the default |
| k8s-infra | `~/Code/infrastructure/k8s-infra` | "infra" tenant — shared prerequisites (storage classes, PKI/cert-manager, gateway, network policy) | The app needs a prerequisite that doesn't exist yet |

Runtime constants (from `k8s-fleet/clusters/turing/runtime-info.yaml`): `ENVIRONMENT=prod`, `GIT_BRANCH=main`, cluster `turing`. Existing categories in k8s-apps: `docs`, `infra`, `media`, `tools`.

## Steps

0. **Start from a clean worktree.** For each repo you'll touch (k8s-apps, and k8s-fleet/k8s-infra if needed), `git -C <repo> checkout main && git -C <repo> pull`, then create a fresh worktree off `main` for this task rather than editing in place.
   Done when: you're working in a new worktree based on an up-to-date `main`, for every repo you'll edit.

1. **Classify the app.** Pick its category and name. Confirm the category is wired: `k8s-fleet/tenants/apps/components/<category>.yaml` must exist and be listed in `tenants/apps/components/kustomization.yaml`'s `resources:`. If the category is new, copy an existing `components/<category>.yaml` (e.g. `media.yaml`), rename the Kustomization to `apps-<category>`, set `path: components/<category>/${ENVIRONMENT}`, and add the file to `components/kustomization.yaml`.
   Done when: category chosen and its Flux Kustomization exists in k8s-fleet.

2. **Pick the deploy method.** Look for an official upstream Helm chart (classic repo or OCI). If one exists, use the HelmRelease pattern; otherwise use the raw Kustomize-manifest pattern (see TEMPLATES.md for both). Don't guess — check the upstream project's actual release artifacts.
   Done when: method chosen and matches what upstream actually publishes.

3. **Scaffold `k8s-apps/components/<category>/base/<app>/`** per the chosen pattern in TEMPLATES.md. Every app gets its own `namespace.yaml` and a self-contained `kustomization.yaml`. Any credential the app needs (API/session secret, OIDC client secret, DB password not already owned by an operator) follows the Secrets section below — never a literal value you invented. Keep the base **environment-agnostic**: only values identical in every environment. Anything that would differ per environment — external hostnames/URLs, per-env secrets, replica counts, resource sizing — belongs in the overlay (step 4), not here.
   Done when: `kubectl kustomize components/<category>/base/<app>` builds with no errors and holds no **environment-specific** values (no external hostnames, no secrets).

4. **Scaffold `k8s-apps/components/<category>/prod/<app>/`** — overlay referencing `../../base/<app>`, plus any prod-only resources (extra storage, patches, routes). This overlay owns the **environment-specific** settings the base omits: external hostnames/URLs (e.g. `SERVER_URL`), per-env secrets (see Secrets), sizing. Layer them onto the base instead of forking files — `configMapGenerator`/`secretGenerator` with `behavior: merge`/`replace`, or a `patches:` entry — and keep any external hostname here consistent with the route's (step 8).
   Done when: `kubectl kustomize components/<category>/prod/<app>` builds with no errors.

5. **Wire it in**: add `<app>` to the `resources:` list of `k8s-apps/components/<category>/prod/kustomization.yaml`.
   Done when: the app directory is in that list.

6. **Track new versions**, by exactly one mechanism:
   - Kustomize-manifest apps: add `k8s-apps/update/<category>-<app>.yaml` (`ImageRepository` + `ImagePolicy`), register it in `update/kustomization.yaml`, and add the matching `{"$imagepolicy": "flux-system:<category>-<app>-<image>:name"}` / `:tag` markers to the base `kustomization.yaml`'s `images:` block.
   - Helm apps: pin a semver range on the source instead — `chart.spec.version` (HelmRepository) or `ref.semver` (OCIRepository). No ImagePolicy needed.
   Done when: version tracking exists via exactly one of these, not both, not neither.

7. **Check k8s-infra for prerequisites** the app's manifests reference — `storageClassName`, `issuerRef`, gateway listener, network policy. Only edit k8s-infra if something required is actually missing.
   Done when: every prerequisite referenced resolves to something already in k8s-infra, or you added it there.

8. **Expose externally if needed** — add `routes.yaml` (HTTPRoute) to the prod overlay: hostname `<app>.app.stignet.com`, `parentRefs: [{name: app, namespace: envoy-gateway-system}]`. Skip this for internal-only apps.
   Done when: HTTPRoute added, or explicitly skipped with a reason.

9. **Verify**, after the changes are committed and pushed (leave the commit to the user unless asked):
   - `flux reconcile source git flux-apps -n flux-system --timeout 2m` (add `flux-infra` too if k8s-infra changed)
   - `flux reconcile kustomization apps-<category> -n flux-system --with-source`
   - `flux get helmreleases -n <namespace>` or `flux get kustomizations -A` — expect `Ready: True`
   - `kubectl get pods -n <namespace>` — expect `Running`
   Done when: the relevant Flux object is Ready and its pods are Running. If not, see Troubleshooting.

## Secrets

Never generate a secret value yourself (no `secrets.token_urlsafe`, no random passwords, no invented API keys) and never write one — real or placeholder-that-looks-real — into a committed file. Assume the human wires in every sensitive value after the app is scaffolded.

- Prefer the app's own `existingSecret`/`secretRef`-style config field (most Helm charts and many raw manifests have one) over an inline value, so the Secret name/keys you reference are exactly what a `secretGenerator` produces.
- Scaffold the `secretGenerator` in the **overlay** `kustomization.yaml` (secrets are environment-specific — step 3) pointing at a `<name>.sops.env` file — via `envs:` for a whole file or `files:`/`literals:` as needed — but do not create that `.sops.env` file's contents. Tell the user its path, the keys it must contain, and that they need to write and encrypt it themselves (`sops -e -i <file>`, matching the repo's `.sops.yaml` creation rules) before the HelmRelease/Deployment will come up healthy.
- If the chart has no `existingSecret` knob and only takes a raw value in `values.yaml`/env, still don't fabricate one — scaffold the `secretGenerator` + `.sops.env` reference and wire the resulting Secret in via `valueFrom.secretKeyRef` (raw manifests) or a values/patch override that reads from the Secret, not a literal.
- Passwords already owned by an operator (e.g. CNPG's auto-generated `<cluster>-app` Secret) aren't your concern — reference them by name, don't touch their contents.
- Flag every secret left for the user in your final summary as a punch list (Secret name, namespace, expected keys), the same way step 9's verification failures get surfaced.

## Troubleshooting

- HelmRelease stuck "install retries exceeded" → `flux get helmrelease <name> -n <ns>` for the error, then `kubectl describe` the failed underlying resource.
- Kustomization "path not found" → category not wired in k8s-fleet yet, or a typo in `${ENVIRONMENT}`.
- ImagePolicy never updates → marker comment on the wrong field/line, or the ImageRepository can't reach the registry (`flux get image repository`).
- PVC stuck Pending → `storageClassName` doesn't exist in k8s-infra, or (SMB-backed PVs) the `volumeHandle` collides with an existing one.
- Resource never applies → its `namespace:` doesn't match the one the base `kustomization.yaml` sets.
