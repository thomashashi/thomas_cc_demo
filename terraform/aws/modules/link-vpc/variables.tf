# Required

variable "hashi_tags" {
  type = "map"

  default = {
    "TTL"     = ""
    "owner"   = ""
    "project" = ""
  }
}

variable "aws_region_main" {
  description = "Main AWS Region"
}

variable "aws_region_alt" {
  description = "Alt AWS Region"
}

variable "vpc_id_main" {
  description = "Main VPC ID"
}

variable "vpc_id_alt" {
  description = "Alt VPC ID"
}

variable "route_table_id_main" {
  description = "Main VPC Route Table ID"
}

variable "route_table_id_alt" {
  description = "Alt VPC Route Table ID"
}
