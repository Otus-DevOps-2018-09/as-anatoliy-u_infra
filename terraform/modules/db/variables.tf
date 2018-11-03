variable name {
  description = "Resource name, e.g.: reddit-db"
  default     = "reddit-db"
}

variable zone {
  description = "Zone"
}

variable tags {
  type    = "list"
  default = ["reddit-db"]
}

variable source_tags {
  type    = "list"
  default = ["reddit-app"]
}

variable firewall_ports {
  type    = "list"
  default = ["27017"]
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for provisioners"
}

variable disk_image {
  description = "Reddit DB image"
  default     = "reddit-db-base"
}
