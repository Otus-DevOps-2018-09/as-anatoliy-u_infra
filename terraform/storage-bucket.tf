provider "google" {
  version = "~> 1.19"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = ["backend-stage", "backend-prod"]
}

output "project-backend-bucket-url" {
  value = "${module.storage-bucket.url}"
}
