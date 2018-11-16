terraform {
  backend "gcs" {
    bucket = "backend-stage"
    prefix = "terraform/state"
  }
}
