resource "google_storage_bucket"  "website" {
    name = "example-website-by-ghtfghy"
    location = "US"
}

resource "google_storage_bucket_access_control" "public_rule" {
     object = google_storage_bucket_object.static_site_src.name
     bucket =  google_storage_bucket.website.name
     role = "READER"
     entity = "allUsers" 
}

resource "google_storage_bucket_object" "static_site_src" {
    name = "index.html"
    source = "../website/index.html"
    bucket = google_storage_bucket.website.name
}
 
resource ""google_compute_global_address" "website_ip" {
    name = "website-lb-ip"
}

data "google_dns_managed_zone" "dns_zone" {
    name = "my-example"
}

resource "google_dns_record_set" "website" {
    name = "website.${data.google_dns_managed_zone.dns_zone.dns_name}"
    type = "A"
    ttl = 300
    managed_zone = data.google_dns_managed_zone.dns_zone.name
    rrdatas =  [google_compute_global_address.website_ip.address]
}

resource "google_compute_backend_bucket" "website-backend" {
    name = "website_bucket" 
    bucket_name = google_storage_bucket.website.name   
    description = "contains what should be contained"
    enable_cdn = true
}

resource "goole_compute_url_map" "website" {
    name = "website-url-map"
    default_service = google_compute_backend_bucket.website_bucket.self_link
    host_rule {
        hosts = ["*"]
        path_matcher = "allPaths"
    }
    path_matcher{
        name = "allPaths"
        default_service = google_compute_backend_bucket.website-backend.self_link
    }
}

resource "goole_compute_target_http_proxy"  "website" {
    name = "website-target"
    url_map = google_compute_url_map.website.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
    name = "website-forwarding-rule"
    load_balancing_scheme = "EXTERNAL"
    ip_address = google_compute_global_address.website_ip.address
    ip_protocol = "TCP"
    port_range = "80"
    target = google_compute_target_http_proxy.website.self_link
}


