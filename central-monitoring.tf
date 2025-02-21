
# Pub/Sub topic for metrics sink in central monitoring project
resource "google_pubsub_topic" "metrics_sink_topic" {
  project = google_project.project.project_id
  name    = "metrics-sink-topic"
  depends_on = [ time_sleep.wait_project_init ]
}

# Pub/Sub subscription (optional)
resource "google_pubsub_subscription" "metrics_sink_subscription" {
  project = google_project.project.project_id
  name    = "metrics-sink-subscription"
  topic   = google_pubsub_topic.metrics_sink_topic.id
}

# Organization-wide metrics sink
resource "google_logging_organization_sink" "metrics_sink" {
  name        = "metrics-sink"
  org_id      = var.org_id
  destination = "pubsub.googleapis.com/projects/${google_project.project.project_id}/topics/${google_pubsub_topic.metrics_sink_topic.name}"
  filter      = "resource.type=global" # Filter can be refined for specific metrics
}

# Grant Pub/Sub publishing rights for all projects in organization
#resource "google_pubsub_topic_iam_member" "metrics_sink_publisher" {
#  project = google_project.project.project_id
#  topic   = google_pubsub_topic.metrics_sink_topic.id
#  role    = "roles/pubsub.publisher"
#  member  = "serviceAccount:service-${google_project.project.number}@gcp-sa-monitoring.iam.gserviceaccount.com"
#}

# Allow sink writer to publish to Pub/Sub topic
resource "google_pubsub_topic_iam_member" "sink_writer" {
  project = google_project.project.project_id
  topic   = google_pubsub_topic.metrics_sink_topic.id
  role    = "roles/pubsub.publisher"
  member  = google_logging_organization_sink.metrics_sink.writer_identity
}

