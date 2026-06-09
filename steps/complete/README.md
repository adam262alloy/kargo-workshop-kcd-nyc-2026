# Complete Pipeline

This is the finished project, every step from 1–9 combined, here for your reference purposes.

## Resources

- `project.yaml`: Project + `ProjectConfig` promotion policies.
- `warehouse.yaml`: image + git `Warehouse`.
- `stages.yaml`: `dev`, `staging`, `prod`, and the three regional prod Stages with verification, PR/ServiceNow gates, and Terraform/Lambda steps.
- `analysis.yaml`: verification `AnalysisTemplate`s.
- `custom-steps.yaml`: Trivy + hello-world `CustomPromotionStep`s.
- `notifications.yaml`: SMTP `MessageChannel` + `EventRouter`.

## Docs

- [Kargo docs](https://docs.kargo.io)
- [Promotion steps reference](https://docs.kargo.io/user-guide/reference-docs/promotion-steps)
- [Patterns](https://docs.kargo.io/user-guide/patterns)
