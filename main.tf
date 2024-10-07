provider "google" {
  project = "psenapati-sample"
  region  = "us-central1"
  zone    = "us-central1-a"
}

variable "image_tag" {
  type = string
}

terraform {
 backend "gcs" {
   bucket  = "hello-world-state-file"
   prefix  = "/"
 }
}
data "terraform_remote_state" "foo" {
  backend = "gcs"
  config = {
    bucket  = "hello-world-state-file"
    prefix  = "prod"
  }
}

resource "google_cloud_run_service" "app_service" {
  name     = "hello-world"
  location = "us-central1"
  
  template {
    spec {
      containers {
        image = "gcr.io/psenapati-sample/devops-inter:${var.image_tag}"
      }
    }
  }
}
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.app_service.location
  project = "psenapati-sample"
  service     = google_cloud_run_service.app_service.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
