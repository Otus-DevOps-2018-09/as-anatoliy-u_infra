terraform {
  backend "gcs" {
    bucket = "backend-prod"
    prefix = "terraform/state"
  }
}
