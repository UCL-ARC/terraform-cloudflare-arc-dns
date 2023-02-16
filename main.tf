# Configure the Cloudflare provider with API token.
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Retrieve the zone information for the given zone ID.
data "cloudflare_zone" "zone" {
  zone_id = var.cloudflare_zone_id
}

locals {

  a_records_yaml     = try(yamldecode(var.a_records_yaml),null)
  cname_records_yaml = try(yamldecode(var.cname_records_yaml),null)

  # Maps of hostnames to owner email addresses.
  A_record_owners = {
    for i, j in local.a_records_yaml :
    lookup(cloudflare_record.a-recs[i], "hostname", null) => j.owner_email
  }

  CNAME_record_owners = {
    for i, j in local.cname_records_yaml :
    lookup(cloudflare_record.cname-recs[i], "hostname", null) => j.owner_email
  }

  # Create list of all FQDNs.
  fqdns = concat(values(cloudflare_record.a-recs).*.hostname, values(cloudflare_record.cname-recs).*.hostname)
  # Crate map of all hostnames to owners.
  owners = merge(local.A_record_owners, local.CNAME_record_owners)

}

# Add A records to the zone.
resource "cloudflare_record" "a-recs" {
  for_each = local.a_records_yaml

  zone_id = data.cloudflare_zone.zone.id
  name    = each.key
  value   = each.value.value
  type    = "A"
  # If no TTL is given, then TTL is set to auto.
  ttl = lookup(local.a_records_yaml[each.key], "ttl", 1)
  # If no proxy is specified, then `proxied` is set to true.
  # TTL must = 1 to proxy, or conversely, proxy must be false
  # to have a non-zero TTL and directly resolve IP.
  proxied = lookup(local.a_records_yaml[each.key], "proxy", true)
}

# Add CNAME records to the zone.
resource "cloudflare_record" "cname-recs" {
  for_each = local.cname_records_yaml

  zone_id = data.cloudflare_zone.zone.id
  name    = each.key
  value   = each.value.value
  type    = "CNAME"
  # If no TTL is given, then TTL is set to auto.
  ttl = lookup(local.cname_records_yaml[each.key], "ttl", 1)
  # If no proxy is specified, then `proxied` is set to true.
  # TTL must = 1 to proxy, or conversely, proxy must be false
  # to have a non-zero TTL and directly resolve origin.
  proxied = lookup(local.cname_records_yaml[each.key], "proxy", true)
}