resource "google_compute_firewall" "firewall_ssh" {
  name        = "${var.name}-allow-ssh"
  description = "Allow SSH from source_ranges"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.source_ranges}"
}
