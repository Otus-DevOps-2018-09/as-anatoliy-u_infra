# GCP Load Balancing

# 1. A global forwarding rule directs incoming requests to a target HTTP proxy.
# 2. The target HTTP proxy checks each request against a URL map
#    to determine the appropriate backend service for the request.
# 3. The backend service directs each request to an appropriate backend
#    based on serving capacity, zone, and instance health of attached backends
# 4. The health of each backend instance is verified using a "health check"

# Global forwarding rule
# ->
# HTTP proxy
# ->
# URL map
# ->
# Backend service
#   backends: [
#     Instance group 1,
#     ...
#   ]
#   health_check: Health check
#
# Instance group:
#   instances: [
#     Compute instance 1,
#     ...
#   ]

resource "google_compute_instance_group" "reddit_app_instance_group" {
  name        = "reddit-app-instance-group"
  description = "Reddit App instance group"
  instances   = ["${google_compute_instance.app.*.self_link}"]

  named_port {
    name = "http"
    port = "9292"
  }

  zone = "${var.zone}"
}

resource "google_compute_health_check" "reddit_app_health_check" {
  name               = "reddit-app-health-check"
  description        = "Reddit App health check"
  check_interval_sec = 1
  timeout_sec        = 1

  tcp_health_check {
    port = "9292"
  }
}

resource "google_compute_backend_service" "reddit_app_backend_service" {
  name        = "reddit-app-backend-service"
  description = "Reddit App backend service"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 5

  backend {
    group = "${google_compute_instance_group.reddit_app_instance_group.self_link}"
  }

  health_checks = ["${google_compute_health_check.reddit_app_health_check.self_link}"]
}

resource "google_compute_url_map" "reddit_app_url_map" {
  name            = "reddit-app-url-map"
  description     = "Reddit App URL map"
  default_service = "${google_compute_backend_service.reddit_app_backend_service.self_link}"
}

resource "google_compute_target_http_proxy" "reddit_app_http_proxy" {
  name        = "reddit-app-http-proxy"
  description = "Reddit App HTTP proxy"
  url_map     = "${google_compute_url_map.reddit_app_url_map.self_link}"
}

resource "google_compute_global_forwarding_rule" "reddit_app_global_forwarding_rule" {
  name        = "reddit-app-global-forwarding-rule"
  description = "Reddit App global forwarding rule"
  target      = "${google_compute_target_http_proxy.reddit_app_http_proxy.self_link}"
  port_range  = "80"
}
