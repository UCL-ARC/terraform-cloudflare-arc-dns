# Token with Edit rights for the given zone.
variable "cloudflare_api_token" {
  sensitive = true
}

# ID of the target zone.
variable "cloudflare_zone_id" {
  sensitive = true
}

# YAML containing one or more A records
variable "a_records_yaml" {
  default = {}
}

# YAML containing one or more CNAME records
variable "cname_records_yaml" {
  default = {}
}