variable "aws" {
    default = "us-east-1"
    type = string
}

variable "project_name" {
  description = "The name of the current project we're working with"
  type        = string
  default     = "ata-tf-project"
}

