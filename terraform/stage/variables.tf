variable project {
  description = "Project ID"
}

variable environment {
  description = "Project environment, e.g. test, stage, prod, etc."
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable app_disk_image {
  description = "App image"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "DB image"
  default     = "reddit-db-base"
}

variable allow_source_ranges {
  type        = "list"
  description = "Allowed IP addresses"
}
