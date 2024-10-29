# Compute instance resource
resource "google_compute_instance" "grafana_instance" {
  name         = var.instance_name
  machine_type = var.instance_type
  zone         = var.zone
  tags         = var.enable_lb ? ["allow-load-balancer", "allow-iap-ssh"] : ["allow-iap-ssh"]

  # Specify the network interface
  network_interface {
    network    = var.network
    subnetwork = var.subnet
    access_config {
      # Disable external IP
      nat_ip = null
    }
  }

  # Boot disk with Ubuntu image
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  # Metadata configuration
  metadata = {
    enable-oslogin      = var.enable_oslogin ? "TRUE" : "FALSE"
    enable-oslogin-2fa  = var.enable_oslogin_2fa ? "TRUE" : "FALSE"
  }

  # Provisioning script to install Grafana
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apt-transport-https software-properties-common wget
    wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
    add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    apt-get update
    apt-get install -y grafana
    systemctl daemon-reload
    systemctl enable grafana-server
    systemctl start grafana-server
  EOT
}

# Firewall rule to allow SSH through IAP
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = var.network

  direction = "INGRESS"
  priority  = 1000
  target_tags = ["allow-iap-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

# Firewall rule to allow Load Balancer to access Grafana (port 3000)
resource "google_compute_firewall" "allow_lb_grafana" {
  count       = var.enable_lb ? 1 : 0
  name        = "allow-lb-grafana"
  network     = var.network

  direction   = "INGRESS"
  priority    = 1000
  target_tags = ["allow-load-balancer"]

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  # Allow traffic from any source to port 3000
  source_ranges = ["0.0.0.0/0"]
}

# Cloud NAT configuration (conditional)
resource "google_compute_router" "nat_router" {
  count    = var.enable_nat ? 1 : 0
  name     = "${var.project}-nat-router"
  region   = var.region
  network  = var.network
}

resource "google_compute_router_nat" "nat_config" {
  count                      = var.enable_nat ? 1 : 0
  name                       = "${var.project}-nat"
  router                     = google_compute_router.nat_router[0].name
  region                     = var.region
  nat_ip_allocate_option     = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Health check for Load Balancer
resource "google_compute_health_check" "grafana_health_check" {
  count = var.enable_lb ? 1 : 0
  name               = "grafana-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = 3000
  }
}

# Unmanaged Instance Group with Named Port
resource "google_compute_instance_group" "grafana_instance_group" {
  name    = "${var.instance_name}-group"
  zone    = var.zone
  network = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/${var.network}"
  instances = [google_compute_instance.grafana_instance.self_link]

  # Named port for Grafana on port 3000
  named_port {
    name = "grafana"
    port = 3000
  }
}

# Backend service using the instance group on port 3000
resource "google_compute_backend_service" "grafana_backend" {
  count                 = var.enable_lb ? 1 : 0
  name                  = "grafana-backend-service"
  protocol              = "HTTP"
  port_name             = "grafana" # Referencing the named port in the instance group
  health_checks         = [google_compute_health_check.grafana_health_check[0].id]
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_instance_group.grafana_instance_group.id
  }
}

# URL Map
resource "google_compute_url_map" "grafana_url_map" {
  count           = var.enable_lb ? 1 : 0
  name            = "grafana-url-map"
  default_service = google_compute_backend_service.grafana_backend[0].id
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "grafana_http_proxy" {
  count    = var.enable_lb ? 1 : 0
  name     = "grafana-http-proxy"
  url_map  = google_compute_url_map.grafana_url_map[0].id
}

# Global Forwarding Rule for external access
resource "google_compute_global_forwarding_rule" "grafana_forwarding_rule" {
  count                 = var.enable_lb ? 1 : 0
  name                  = "grafana-forwarding-rule"
  target                = google_compute_target_http_proxy.grafana_http_proxy[0].id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
  ip_version            = "IPV4"
}
