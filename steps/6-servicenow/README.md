# Step 6 — ServiceNow Change Gate

Add a ServiceNow change-management gate to `prod`. The promotion opens a change request
(`snow-create`), blocks until the ticket reaches the **Implement** state
(`snow-wait-for-condition`), applies the change, then closes the request out afterward
(`snow-update`). This mirrors a real enterprise change process.

This needs the `kargo-step-snow` secret (ServiceNow API token + instance URL).

## Resources

- `stages.yaml`: `prod` now wraps its promotion in the ServiceNow steps.
- `message-channel.yaml`, `analysis.yaml`, `project.yaml`, `warehouse.yaml`: unchanged.

## Docs

- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
- [Kargo docs](https://docs.kargo.io)
