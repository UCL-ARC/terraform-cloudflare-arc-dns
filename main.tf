# Configure the Cloudflare provider with API token.
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Retrieve the zone information for the given zone ID.
data "cloudflare_zone" "zone" {
  zone_id = var.cloudflare_zone_id
}

locals {

  a_records_yaml     = try(yamldecode(var.a_records_yaml), {})
  cname_records_yaml = try(yamldecode(var.cname_records_yaml), {})

  # Complete set of owners for A or CNAME records.
  record_owners = toset(concat(
    [for record in local.a_records_yaml : record.owner_email],
    [for record in local.cname_records_yaml : record.owner_email]
  ))

  # Map of hostnames to owner email addresses.
  record_owners_and_hostnames = {
    for owner in local.record_owners :
    "${owner}" => compact(
      concat(
        [for k, v in cloudflare_record.a-recs : local.a_records_yaml[k].owner_email == owner ? v.hostname : null],
        [for k, v in cloudflare_record.cname-recs : local.cname_records_yaml[k].owner_email == owner ? v.hostname : null]
      )
    )
  }

  # Create list of all FQDNs.
  fqdns = concat(values(cloudflare_record.a-recs).*.hostname, values(cloudflare_record.cname-recs).*.hostname)
}

# Add A records to the zone.
resource "cloudflare_record" "a-recs" {
  for_each = local.a_records_yaml

  zone_id = data.cloudflare_zone.zone.id
  name    = can(each.value.name) ? each.value.name : each.key
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
  name    = can(each.value.name) ? each.value.name : each.key
  value   = each.value.value
  type    = "CNAME"
  # If no TTL is given, then TTL is set to auto.
  ttl = lookup(local.cname_records_yaml[each.key], "ttl", 1)
  # If no proxy is specified, then `proxied` is set to true.
  # TTL must = 1 to proxy, or conversely, proxy must be false
  # to have a non-zero TTL and directly resolve origin.
  proxied = lookup(local.cname_records_yaml[each.key], "proxy", true)
}
