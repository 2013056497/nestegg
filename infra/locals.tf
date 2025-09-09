locals {
  name       = "${var.project}-${var.env}"
  account_id = var.aws_account_id
  tags = {
    Project = var.project
    Env     = var.env
    Owner   = "${var.github_org}/${var.github_repo}"
  }
}
