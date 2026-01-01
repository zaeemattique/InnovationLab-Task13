terraform {
  backend "s3" {
    bucket         = "zaeem-terraform-state-bucket"
    key            = "ecs/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}