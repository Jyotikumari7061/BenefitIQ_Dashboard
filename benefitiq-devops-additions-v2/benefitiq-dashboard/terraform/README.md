# Infrastructure (Terraform)

Provisions AWS resources to run BenefitIQ on ECS Fargate behind an ALB,
with secrets in Secrets Manager, remote state in S3, and a GitHub Actions
OIDC role for CI/CD deploys.

## What's here now

- VPC, public subnets (2 AZs), security groups
- ALB + target group + listener, health-checked against `/health`
- ECR repositories for both images
- ECS cluster + Fargate service/task definition for the backend, fronted
  by the ALB (not exposed via public IP directly)
- Secrets Manager entries for `SECRET_KEY` (auto-generated) and
  `DATABASE_URL` (placeholder — set the real value once RDS/managed
  Postgres exists), read by the ECS task at runtime
- GitHub Actions OIDC provider + a deploy role scoped to this exact repo
  and the `main` branch — no long-lived AWS keys in GitHub secrets
- Remote state in S3 with DynamoDB locking (see below)

## What's still deliberately out of scope

- **No RDS** — `DATABASE_URL` is a placeholder secret. Provisioning a real
  Postgres instance is a natural next step, not done here because it's a
  recurring cost for a portfolio project rather than a one-time apply.
- **No frontend ECS service** — only the backend runs on Fargate; the
  frontend task definition would follow the same pattern.
- **Single AZ pair, no autoscaling, no WAF, no HTTPS/ACM cert** — this is
  a demonstrable pattern, not a production-hardened deployment. Say so if
  it comes up.

## One-time setup: remote state

State can't reference its own backend, so the S3 bucket + DynamoDB lock
table live in a separate `bootstrap/` config, applied once with local
state:

```bash
cd terraform/bootstrap
terraform init
terraform apply -var="project_name=benefitiq"
# note the two outputs: state_bucket_name, lock_table_name
```

Then initialize the main config against that backend:

```bash
cd ../
terraform init \
  -backend-config="bucket=<state_bucket_name>" \
  -backend-config="key=benefitiq/terraform.tfstate" \
  -backend-config="region=ap-south-1" \
  -backend-config="dynamodb_table=<lock_table_name>"
```

## Usage

```bash
terraform plan \
  -var="aws_region=ap-south-1" \
  -var="github_repo=Jyotikumari7061/benefitiq-dashboard"
terraform apply \
  -var="aws_region=ap-south-1" \
  -var="github_repo=Jyotikumari7061/benefitiq-dashboard"
```

After apply, take the `github_actions_deploy_role_arn` output and set it
as the `AWS_DEPLOY_ROLE_ARN` secret in the GitHub repo (Settings → Secrets
and variables → Actions), plus these repo **variables**:
`AWS_REGION`, `ECS_CLUSTER_NAME`, `ECS_SERVICE_NAME`, `ECR_BACKEND_REPO`,
`ECR_FRONTEND_REPO`, `VITE_API_BASE_URL`. That's what closes the loop
between the CI/CD workflow and this infrastructure — without it, the
pipeline builds images with nowhere real to deploy them.

Requires AWS credentials configured locally (`aws configure`) with
permissions for VPC, ECS, ECR, ALB, IAM, Secrets Manager, S3, DynamoDB,
and CloudWatch Logs for the initial apply. Tear down with
`terraform destroy` when not actively demoing it — ALB + NAT-less Fargate
should stay close to free-tier, but check your AWS billing dashboard.

## Honest state of this: not yet run

I wrote and syntax-checked this, but did not run `terraform init/plan/apply`
against a real AWS account — no `terraform` binary or AWS credentials were
available in the environment this was built in. Run it yourself, watch it
apply, and be ready to say what broke and how you fixed it — that's the
part that actually holds up in an interview.
