terraform {
  required_version = "~>1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.14.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
