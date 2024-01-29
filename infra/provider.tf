provider "google" {
    credentials =   file(var.gcp_svc_ley)
    project = var.gcp_project
    region = var.gcp_region
}