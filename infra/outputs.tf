output "state_bucket"     { value = aws_s3_bucket.tfstate.id }
output "lock_table"       { value = aws_dynamodb_table.tf_locks.name }
output "ecr_backend_url"  { value = aws_ecr_repository.backend.repository_url }
output "ecr_frontend_url" { value = aws_ecr_repository.frontend.repository_url }
output "deploy_role_arn"  { value = aws_iam_role.gha_deploy.arn }
