# enable terraform remote backend and state locking
terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  }
}