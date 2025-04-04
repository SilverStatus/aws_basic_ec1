# enable terraform remote backend and state locking
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-1234567890"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_locks"
  }
}