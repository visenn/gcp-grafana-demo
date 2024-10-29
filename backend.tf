terraform {
  backend "gcs" {
    bucket = "cft-demo-vis-state-files"
    prefix = "terraform/state/gcp-grafana-demo"
  }
}
