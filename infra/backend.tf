terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
  backend "s3" {
    bucket       = "nestegg-tfstate-871826696853"
    key          = "global/terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = true
  }
}
