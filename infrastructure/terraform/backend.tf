terraform {
  backend "s3" {
    bucket = "yifat-avishag-roman-tf-state"
    key    = "pipeline/terraform.tfstate"
    region = "us-east-1"
  }
}
