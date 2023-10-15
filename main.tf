# Provider is AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  alias = "eu"
  region = var.region
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a random uuid
resource "random_uuid" "project_id" {
}