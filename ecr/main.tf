provider "aws" {
  region = "${var.region}"
}

resource "aws_ecr_repository" "app_registry" {
  name = "${var.app_name}"
}
