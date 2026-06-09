# Step 1 — Your First Promotion

Start with the minimum pipeline: a `Warehouse` that watches the guestbook image
(`ghcr.io/<your_username>/kargo-workshop-kcd-nyc-2026`) plus the git repo, and a single `dev`
`Stage`. Promoting freight to `dev` updates the dev image tag in git and syncs the `guestbook-dev`
Argo CD app. With no promotion policies yet, every promotion is manual — perfect for running your
first one by hand.

Once it's running, try the UI: assemble freight manually, explore the Promotion Advisor, then kick
off a promotion, and explore the audit log

## Resources

- `project.yaml`: the `guestbook` Project (no policies yet).
- `warehouse.yaml`: `Warehouse` subscribed to the image + git repo.
- `stages.yaml`: the `dev` Stage.

## Docs

- [Kargo docs](https://docs.kargo.io): Stages, freight flow, and promotion policies.
- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
