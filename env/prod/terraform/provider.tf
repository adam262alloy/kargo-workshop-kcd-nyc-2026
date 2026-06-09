terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    bucket       = "kcd-workshop"
    region       = "us-east-1"
    key          = "${var.participant}/prod/terraform.tfstate"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}
