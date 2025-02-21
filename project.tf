resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account_id
  deletion_policy = "DELETE"
}

# resource "time_sleep" "wait_project_create" {
#   count = var.create_project ? 1 : 0
#   create_duration = "20s"

#   depends_on = [google_project.project[0]]
# }

# data google_project "project" {
#   project_id = var.project_id
# }

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project  = google_project.project.project_id
  service  = each.key
}

resource "time_sleep" "wait_project_init" {
  create_duration = "120s"

  depends_on = [google_project_service.gcp_services[0]]
}