terraform {
  backend "s3" {
    bucket  = "djanjo-school-management-bucket-v1"
    key     = "terraform.tfstate"
    encrypt = true
  }
}
