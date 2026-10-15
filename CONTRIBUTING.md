# Contributing

This repo is the design and deployment record for a HIPAA aligned patient portal on AWS. It holds documents and a budget file, not application code:

- `ARCHITECTURE.md`: the VPC design, the network layout in us-east-1, and the control table
- `COMPLIANCE.md`: how each HIPAA safeguard maps to an AWS control
- `COST_OPTIMIZATION.md`: where the money goes and what was traded away
- `DEPLOYMENT.md`: the step-by-step deployment guide
- `budget.json`: the cost budget the design is checked against

## Prerequisites

From the deployment guide, for anyone verifying a change against real infrastructure:

- An AWS account with admin permissions
- Terraform v1.5+
- AWS CLI configured

## How changes work here

There is no automated test suite and no CI in this repo. A change is checked by reading it end to end and keeping the files in agreement with each other.

- Design change: update `ARCHITECTURE.md`. If a HIPAA control mapping moves with it, update `COMPLIANCE.md` in the same PR. Control references use HIPAA section numbers, such as §164.312(b) for audit controls and §164.312(a)(1) for access control. The tables in the two files must not disagree.
- Cost change: update `COST_OPTIMIZATION.md` and `budget.json` together. A claim about cost in the text needs a matching number in the budget.
- Deployment change: `README.md` and `DEPLOYMENT.md` carry the same steps (`terraform init`, `terraform apply`, `terraform output rds_endpoint`). Change both, or neither.
- Never commit AWS keys, real account identifiers, or any patient data to this repo. Examples use placeholders, and they stay placeholders.

## Branches and commits

- Branch names: short and plain, such as `docs/audit-log-retention` or `fix/subnet-table-typo`.
- Commit subjects: short, imperative, one change per commit. Example: `Align flow log retention with the compliance table`.
- Keep each PR to one topic. A control change and a cost change are two PRs.

## Pull requests

- Fill in the PR template. Name the files you changed and say which control mappings or budget lines moved.
- If you ran the Terraform commands from the deployment guide to check a change, say which account type you ran them in (a scratch account, never one holding real patient data) and what `terraform output rds_endpoint` returned in shape, not the real endpoint value.
