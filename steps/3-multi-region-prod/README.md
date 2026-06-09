# Step 3 — Multi-Region Prod

Add production as a control/gate plus a regional fan-out. A `prod` `Stage` (manual gate,
downstream of `staging`) renders values for all three regions. Three regional Stages:
(`prod-amer-east`, `prod-amer-west`, `prod-emea`) sit downstream of `prod` and auto-promote, each
syncing its own Argo CD app. Once everything is promoted, try accessing the guestbook app by running:

```sh
kubectl port-forward -n guestbook-prod-emea svc/guestbook 8080:80
```

Then access `http://localhost:8080` in your browser to see the prod version of the app.

## Resources

- `project.yaml`: `ProjectConfig` auto-promoting `dev` and (via `regex:prod-.*`) the regional
  stages; `staging`/`prod` stay manual.
- `warehouse.yaml`: unchanged image + git `Warehouse`.
- `stages.yaml`: `dev`, `staging`, `prod`, and the three regional Stages.

## Docs

- [Kargo docs](https://docs.kargo.io): Stages and freight flow.
- [Patterns (incl. fan-out)](https://docs.kargo.io/user-guide/patterns)
- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
