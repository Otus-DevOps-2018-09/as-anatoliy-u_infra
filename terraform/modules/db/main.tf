locals {
  address = "${google_compute_address.db_internal_ip.address}"
}

resource "google_compute_instance" "db" {
  name         = "${var.name}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = "${var.tags}"

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default"
    network_ip    = "${local.address}"
    access_config = {
      nat_ip = "${google_compute_address.db_external_ip.address}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/ *bindIp:.*/  bindIp: ${local.address}/' /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
}

resource "google_compute_address" "db_external_ip" {
  name = "${var.name}-external-ip"
}

resource "google_compute_address" "db_internal_ip" {
  name         = "${var.name}-internal-ip"
  address_type = "INTERNAL"
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "${var.name}-allow-mongo"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = "${var.firewall_ports}"
  }

  # apply rule to instances:
  target_tags = "${var.tags}"

  # open ports for instances:
  source_tags = "${var.source_tags}"
}
