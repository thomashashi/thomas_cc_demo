resource "google_compute_instance" "servers-east" {
  provider     = "google.east"
  count        = "${var.servers_count}"
  name         = "server-east-${count.index + 1}"
  machine_type = "${var.server_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  tags = [
    "consul-server",
  ]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.east-server.self_link}"
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

resource "google_compute_instance" "servers-east-vault" {
  provider     = "google.east"
  count        = "1"
  name         = "server-east-vault"
  machine_type = "${var.server_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  depends_on = [
    "google_kms_crypto_key.vault-key", 
    "google_compute_instance.servers-east"
  ]

  tags = [
    "vault-server",
  ]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.east-vault-server.self_link}"
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
    scopes = [
      "https://www.googleapis.com/auth/compute.readonly",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  allow_stopping_for_update = true

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "vault operator init -stored-shares=1 -recovery-shares=1 -recovery-threshold=1 -key-shares=1 -key-threshold=1 > /tmp/unseal",
      "sudo mv /tmp/unseal /etc/vault"
    ]

    connection {
      type  = "ssh"
      user  = "deploy"
      agent = true
    }
  }
}
