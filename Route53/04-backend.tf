terraform {
  backend "s3" {
    bucket  = "capstone-statefile"
    key     = "terraform.tfstate"
    encrypt = true
  }
}


