# ---------------------------------------------------------------------------
# Replaces the `SECRET_KEY: ${SECRET_KEY:-dev-secret-change-in-production}`
# plaintext default in docker-compose.yml. That fallback is fine for local
# dev only — anything deployed pulls real values from Secrets Manager.
# ---------------------------------------------------------------------------
resource "random_password" "jwt_secret" {
  length  = 48
  special = false
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "${var.project_name}/jwt-secret-key"
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = random_password.jwt_secret.result
}

resource "aws_secretsmanager_secret" "database_url" {
  name = "${var.project_name}/database-url"
}

# Placeholder version — real value should point at your RDS/managed Postgres
# connection string once that's provisioned. Not created here: see
# terraform/README.md for why RDS is intentionally out of scope for now.
resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = "postgresql://REPLACE_ME:REPLACE_ME@REPLACE_ME:5432/benefitiq"

  lifecycle {
    ignore_changes = [secret_string] # so `terraform apply` doesn't clobber the real value once you've set it via console/CLI
  }
}

resource "aws_iam_role_policy" "ecs_read_secrets" {
  name = "${var.project_name}-ecs-read-secrets"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = [
        aws_secretsmanager_secret.jwt_secret.arn,
        aws_secretsmanager_secret.database_url.arn,
      ]
    }]
  })
}
