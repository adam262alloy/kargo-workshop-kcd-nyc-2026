# Step 5 — PR Approval Gate

Add a human pull-request approval gate to `staging`. Instead of committing straight to the branch
Argo CD watches, the promotion pushes to a generated branch, opens a PR, sends an email containing
the PR link, and then blocks until the PR is merged. The merge is the approval that lets the
promotion finish.

The email uses an SMTP `MessageChannel` plus a `send-message` promotion step. This needs the
`smtp-credentials` secret, and `from:` in `message-channel.yaml` must be set to the authenticated
SMTP account (replace `REPLACE_WITH_SMTP_FROM_ADDRESS`).

## Resources

- `message-channel.yaml`: SMTP `MessageChannel` (references `smtp-credentials`).
- `stages.yaml`: `staging` now opens a PR, sends the email, and waits for merge.
- `analysis.yaml`, `project.yaml`, `warehouse.yaml`: unchanged.

## Docs

- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
- [Notifications /
  MessageChannel](https://docs.kargo.io/user-guide/reference-docs/events/notifications)
- [Kargo docs](https://docs.kargo.io)
