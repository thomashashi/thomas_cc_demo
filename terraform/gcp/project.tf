# Enable necessary services
resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  depends_on = ["google_project_service.service-usage"]
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  depends_on = ["google_project_service.service-usage"]
}

resource "google_project_service" "kms" {
  service = "cloudkms.googleapis.com"
  depends_on = ["google_project_service.service-usage"]
}

resource "google_project_service" "service-usage" {
  service = "serviceusage.googleapis.com"
}