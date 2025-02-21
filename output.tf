# Output the instance IP and Grafana port
output "instance_internal_ip" {
  value = google_compute_instance.grafana_instance.network_interface[0].network_ip
}

output "grafana_port" {
  value = 3000
}

output "grafana_lb_ip" {
  value       = var.enable_lb ? google_compute_global_forwarding_rule.grafana_forwarding_rule[0].ip_address : "Load Balancer is disabled"
  description = "External IP address for Grafana Load Balancer"
}

output "project_id" {
  value = google_project.project.project_id
}
