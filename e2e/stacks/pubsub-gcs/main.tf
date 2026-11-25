terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project      = "e2e-project"
  region       = "us-central1"
  access_token = "dummy-token"

  storage_custom_endpoint = "http://localhost:8443/storage/v1/"
  pubsub_custom_endpoint  = "http://localhost:8443/v1/"
}

resource "google_storage_bucket" "data" {
  name          = "e2e-data-bucket"
  location      = "US"
  force_destroy = true
}

resource "google_pubsub_topic" "events" {
  name = "e2e-events"
}

resource "google_pubsub_subscription" "events_pull" {
  name  = "e2e-events-pull"
  topic = google_pubsub_topic.events.id
}
