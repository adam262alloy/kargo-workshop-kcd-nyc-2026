# Step 9 — Custom Steps

Now we'll have a choose-your-own-adventure step. `CustomPromotionStep` resources let you run any
container as a promotion step, so you can extend Kargo with whatever tooling your pipeline needs. We
define two and wire them into `dev`: a Trivy image vulnerability scan (the committed example) and a
simple `hello-world` step.

## Resources

- `custom-steps.yaml`: the `trivy-image` and `hello-world` `CustomPromotionStep`s.
- `stages.yaml`: `dev` now runs the custom steps during promotion.
- `event-router.yaml`, `message-channel.yaml`, `analysis.yaml`, `project.yaml`, `warehouse.yaml`:
  unchanged.

## Docs

- [Custom steps](https://docs.kargo.io/user-guide/reference-docs/promotion-steps/custom-steps)
- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
- [Kargo docs](https://docs.kargo.io)
