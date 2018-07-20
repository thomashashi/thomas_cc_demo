data "google_compute_network" "east-network" {
  name     = "default"
  provider = "google.east"
}

data "google_compute_zones" "east-azs" {
  provider = "google.east"
}

data "google_compute_image" "east-server" {
  name = "east-gcp-ubuntu-consul-server"
}

data "google_compute_image" "east-vault-server" {
  name = "east-gcp-ubuntu-consul-client-vault-server"
}

data "google_compute_image" "mongodb_server" {
  name = "east-gcp-ubuntu-consul-client-mongodb"
}

data "google_compute_image" "listing_server" {
  name = "east-gcp-ubuntu-consul-client-listing"
}

data "google_compute_image" "product_server" {
  name = "east-gcp-ubuntu-consul-client-product"
}

data "google_compute_image" "webclient_server" {
  name = "east-gcp-ubuntu-consul-client-webclient"
}
