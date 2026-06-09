# Step 2 — Building a Pipeline

Turn the single stage into a pipeline. A new `staging` `Stage` is added downstream of `dev`, so
freight flows `dev -> staging`. A `ProjectConfig` promotion policy auto-promotes `dev` the moment
new freight is discovered, while `staging` stays a manual gate.

## Resources

- `project.yaml`: Project + `ProjectConfig` with an auto-promotion policy for `dev`.
- `warehouse.yaml`: unchanged image + git `Warehouse`.
- `stages.yaml`: `dev` and `staging` Stages (staging requests freight from dev).

## Docs

- [Kargo docs](https://docs.kargo.io): Stages, freight flow, and promotion policies.
- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
- [Promotion Tasks](https://docs.kargo.io/user-guide/reference-docs/promotion-tasks): Not being
  used, but useful to know about
