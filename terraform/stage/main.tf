provider "google" {
  version = "~> 1.19"
  project = "${var.project}"
  region  = "${var.region}"
}

locals {
  app_name = "reddit-app-${var.environment}"
  db_name  = "reddit-db-${var.environment}"
  vpc_name = "reddit-vpc-${var.environment}"
}

module "db" {
  source           = "../modules/db"
  name             = "${local.db_name}"
  tags             = ["reddit", "db", "${local.db_name}", "${var.environment}"]
  source_tags      = ["${local.app_name}"]
  disk_image       = "${var.db_disk_image}"
  zone             = "${var.zone}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
}

module "app" {
  source           = "../modules/app"
  name             = "${local.app_name}"
  tags             = ["reddit", "app", "${local.app_name}", "${var.environment}"]
  disk_image       = "${var.app_disk_image}"
  zone             = "${var.zone}"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  database_url     = "${module.db.internal_ip}"
}

module "vpc" {
  source        = "../modules/vpc"
  name          = "${local.vpc_name}"
  source_ranges = "${var.allow_source_ranges}"
}
