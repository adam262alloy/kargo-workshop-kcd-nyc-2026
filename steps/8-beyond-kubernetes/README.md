# Step 8 — Beyond Kubernetes

Extend promotions past Kubernetes into infrastructure-as-code. `dev`, `staging`, and `prod` now
update Terraform variables (`hcl-update`), apply them (`tf-apply`), and read back the Lambda
Function URL (`tf-output`), injecting that URL into the app's values so the guestbook frontend talks
to a freshly deployed backend. Each stage drives its own `env/<stage>/terraform`.

This needs the `aws-creds` secret and the shared, pre-created Lambda execution role — see the
top-level README's **AWS setup for the Lambda** section.

Once promoted, you can see the Lambda response in the ui by port-forwarding the guestbook:

```sh
kubectl port-forward -n guestbook-prod-emea svc/guestbook 8080:80
```

Then access `http://localhost:8080` in your browser to see the output from the lambda call

## Resources

- `stages.yaml`: `dev`/`staging`/`prod` now include the Terraform/Lambda steps.
- `event-router.yaml`, `message-channel.yaml`, `analysis.yaml`, `project.yaml`, `warehouse.yaml`:
  unchanged.

## Docs

- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
- [Kargo docs](https://docs.kargo.io)
