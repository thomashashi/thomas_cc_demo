resource "google_compute_firewall" "allow-consul-east" {
  provider = "google.east"
  name     = "consul-ui-east"
  network  = "${data.google_compute_network.east-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["8200", "8300", "8301", "8302", "8500"]
  }
}

resource "google_compute_firewall" "allow-consul-wan-east" {
  provider = "google.east"
  name     = "consul-wan-east"
  network  = "${data.google_compute_network.east-network.self_link}"

  allow {
    protocol = "udp"
    ports    = ["8301", "8302"]
  }
}

resource "google_compute_firewall" "allow-services-east" {
  provider = "google.east"
  name     = "http-east"
  network  = "${data.google_compute_network.east-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080"]
  }
}
