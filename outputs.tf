# List of all FQDNs created in DNS.
output "fqdns" {
  value = local.fqdns
}

# Map of hostnames to owner email addresses.
output "owners" {
  value = local.record_owners_and_hostnames
}
