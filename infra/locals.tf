locals {
  name = "${var.project}-${var.env}"
  tags = {
    Project = var.project
    Env     = var.env
    Owner   = "${var.github_org}/${var.github_repo}"
  }
}
