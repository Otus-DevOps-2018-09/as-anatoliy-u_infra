resource "google_compute_instance" "app" {
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
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.app_external_ip.address}"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

#  connection {
#    type        = "ssh"
#    user        = "appuser"
#    agent       = false
#    private_key = "${file(var.private_key_path)}"
#  }

#  provisioner "file" {
#    content     = "${data.template_file.puma_service.rendered}"
#    destination = "/tmp/puma.service"
#  }

#  provisioner "remote-exec" {
#    script = "${path.module}/files/deploy.sh"
#  }
}

resource "google_compute_address" "app_external_ip" {
  name = "${var.name}-external-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "${var.name}-allow-puma"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = "${var.firewall_ports}"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = "${var.tags}"
}

data "template_file" "puma_service" {
  template = "${file("${path.module}/files/puma.service")}"

  vars {
    database_url = "${var.database_url}"
  }
}
