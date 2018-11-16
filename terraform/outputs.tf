# Here is how to output IP of an instance with count > 1
output "app_ips" {
  value = "${join(", ",google_compute_instance.app.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}

output "loadbalancer_ip" {
  value = "${google_compute_global_forwarding_rule.reddit_app_global_forwarding_rule.ip_address}"
}
