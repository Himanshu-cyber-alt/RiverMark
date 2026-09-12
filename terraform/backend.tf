terraform {
  backend "s3" {
    bucket = "rivermark-terraform-state-himanshu-2026"
    key    = "rivermark/terraform.tfstate"
    region = "ap-south-1"
  }
}