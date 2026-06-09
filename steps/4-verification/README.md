# Step 4 — Verification

Add automated verification using Argo Rollouts `AnalysisTemplate`s. Each stage references a template
in its `verification` block, so after a promotion completes Kargo runs the analysis against the
deployed guestbook and only marks the freight **verified** if it passes. `dev` runs a smoke test,
`staging` runs an e2e test, and the regional prod stages each verify their deployment.

## Resources

- `analysis.yaml`: the `AnalysisTemplate`s (smoke, e2e, regional probes).
- `project.yaml`, `warehouse.yaml`: unchanged.
- `stages.yaml`: Stages now with `verification` referencing the templates.

## Extra Credit

What happens if verification fails? Try breaking the guestbook manifests (i.e. you can change the
service port) and seeing what happens

## Docs

- [Kargo docs](https://docs.kargo.io) — Verification and freight qualification.
- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
