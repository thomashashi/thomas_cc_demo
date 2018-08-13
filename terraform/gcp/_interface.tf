# Required
variable "ssh_key_data" {
  description = "Contents of the public key"
}

variable "ssh_user" {
  description = "Username of ssh user created with the ssh_key_data key"
}

# Optional
variable "server_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "n1-standard-1"
}

variable "region" {
  description = "Region into which to deploy"
  default     = "us-east1"
}

variable "client_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "g1-small"
}

variable "servers_count" {
  description = "How many servers to create in each region"
  default     = "3"
}

variable "client_db_count" {
  description = "The number of client machines to create in each region"
  default     = "1"
}

variable "client_product_count" {
  description = "The number of product machines to create in each region"
  default     = "2"
}

variable "client_listing_count" {
  description = "The number of listing machines to create in each region"
  default     = "2"
}

variable "client_index_count" {
  description = "The number of listing machines to create in each region"
  default     = "1"
}

output "server_ips" {
  value = ["${google_compute_instance.servers-east.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "web_client_ips" {
  value = ["${google_compute_instance.index_server.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}
