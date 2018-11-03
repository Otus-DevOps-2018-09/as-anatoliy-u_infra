variable name {
  description = "Resource name, e.g.: reddit-app"
  default     = "reddit-app"
}

variable database_url {
  description = "Reddit DB address"
}

variable zone {
  description = "Zone"
}

variable tags {
  type    = "list"
  default = ["reddit-app"]
}

variable firewall_ports {
  type    = "list"
  default = ["9292"]
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for provisioners"
}

variable disk_image {
  description = "Reddit App image"
  default     = "reddit-app-base"
}
