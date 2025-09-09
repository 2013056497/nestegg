resource "aws_ecs_cluster" "this" {
  name = local.name
  tags = local.tags
}
