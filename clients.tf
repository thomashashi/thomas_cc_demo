# mongo servers
resource "google_compute_instance" "mongodb_server" {
  provider     = "google.east"
  count        = "${var.client_db_count}"
  name         = "client-east-db-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.mongodb_server.self_link}"
    }
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${var.ssh_key_data}"
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true
}

resource "google_compute_instance" "product_server" {
  provider     = "google.east"
  count        = "${var.client_product_count}"
  name         = "client-east-product-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.product_server.self_link}"
    }
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${var.ssh_key_data}"
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true
  depends_on                = ["google_compute_instance.mongodb_server"]
}

resource "google_compute_instance" "listing_server" {
  provider     = "google.east"
  count        = "${var.client_listing_count}"
  name         = "client-east-listing-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.listing_server.self_link}"
    }
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${var.ssh_key_data}"
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true
  depends_on                = ["google_compute_instance.mongodb_server"]
}

resource "google_compute_instance" "index_server" {
  provider     = "google.east"
  count        = "${var.client_index_count}"
  name         = "client-east-index-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.webclient_server.self_link}"
    }
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${var.ssh_key_data}"
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true
}

/*
# products servers
resource "google_compute_region_instance_group_manager" "product-servers" {
  name = "product-servers-igm"

  base_instance_name = "product"
  instance_template  = "${google_compute_instance_template.product-server-instance.self_link}"
  region             = "${var.region}"

  target_size = "${var.product_servers_count}"
}

resource "google_compute_instance_template" "product-server-instance" {
  name        = "product-server-template"
  description = "This template is used to create product server instances."

  instance_description = "Product server template"
  machine_type         = "n1-standard-1"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "${data.google_compute_image.product_server.self_link}"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"
  }

  metadata {
    sshKeys = "${var.ssh_user}:${var.ssh_key_data}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

# listing servers
resource "google_compute_region_instance_group_manager" "listing-servers" {
  name = "listing-servers-igm"

  base_instance_name = "listing"
  instance_template  = "${google_compute_instance_template.listing_server_instance.self_link}"
  region             = "${var.region}"
  target_size        = "${var.listing_servers_count}"
}

resource "google_compute_instance_template" "listing_server_instance" {
  name        = "listing-server-template"
  description = "This template is used to create listing server instances."

  instance_description = "Listing server template"
  machine_type         = "n1-standard-1"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "${data.google_compute_image.listing_server.self_link}"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"
  }

  metadata {
    sshKeys = "${var.ssh_user}:${var.ssh_key_data}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}
*/

