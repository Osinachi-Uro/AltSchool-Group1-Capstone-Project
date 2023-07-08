terraform {
  backend "s3" {
    bucket  = "capstone-statefile-test"
    key     = "terraform.tfstate"
    encrypt = true
  }
}
