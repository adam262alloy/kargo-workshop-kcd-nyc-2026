# Step 7 — Notifications

We add project-wide email notifications. An `EventRouter` subscribes to `PromotionSucceeded`,
`PromotionFailed`, and `PromotionErrored` events and emails a summary for each one, reusing the SMTP
`MessageChannel` from step 5. Now every promotion outcome — not just the staging gate — lands in
your inbox.

## Resources

- `event-router.yaml`: `EventRouter` routing promotion events to the `email` channel.
- `message-channel.yaml`: the SMTP `MessageChannel` (from step 5).
- `stages.yaml`, `analysis.yaml`, `project.yaml`, `warehouse.yaml`: unchanged.

## Extra Credit

Try removing the `output` block from the `EventRouter` and see what happens

## Docs

- [Notifications / EventRouter /
  MessageChannel](https://docs.kargo.io/user-guide/reference-docs/events/notifications)
- [Kargo docs](https://docs.kargo.io)
