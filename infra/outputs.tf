output "state_bucket" { value = aws_s3_bucket.tfstate.id }
output "ecr_backend_url" { value = aws_ecr_repository.backend.repository_url }
output "ecr_frontend_url" { value = aws_ecr_repository.frontend.repository_url }
output "deploy_role_arn" { value = aws_iam_role.gha_deploy.arn }
output "ecs_cluster" { value = aws_ecs_cluster.this.name }
output "ecs_service_backend" { value = aws_ecs_service.backend.name }
output "ecs_task_family_backend" { value = aws_ecs_task_definition.backend.family }
