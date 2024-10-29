
# Pub/Sub topic for metrics sink in central monitoring project
resource "google_pubsub_topic" "metrics_sink_topic" {
  name    = "metrics-sink-topic"
  project = var.project
}

# Pub/Sub subscription (optional)
resource "google_pubsub_subscription" "metrics_sink_subscription" {
  name  = "metrics-sink-subscription"
  topic = google_pubsub_topic.metrics_sink_topic.id
}

# Get organization ID
data "google_organization" "org" {
  organization = "1004792809735"
}

# Get Project number
data "google_project" "project" {
  project_id = var.project
}

# Organization-wide metrics sink
resource "google_logging_organization_sink" "metrics_sink" {
  name         = "metrics-sink"
  org_id = data.google_organization.org.org_id
  destination  = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.metrics_sink_topic.name}"
  filter       = "resource.type=global"  # Filter can be refined for specific metrics
}

# Grant Pub/Sub publishing rights for all projects in organization
resource "google_pubsub_topic_iam_member" "metrics_sink_publisher" {
  topic  = google_pubsub_topic.metrics_sink_topic.id
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-monitoring.iam.gserviceaccount.com"
}

# Allow sink writer to publish to Pub/Sub topic
resource "google_pubsub_topic_iam_member" "sink_writer" {
  topic  = google_pubsub_topic.metrics_sink_topic.id
  role   = "roles/pubsub.publisher"
  member = google_logging_organization_sink.metrics_sink.writer_identity
}

