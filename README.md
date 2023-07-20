# terraform-cloudflare-arc-dns
Terraform module that creates DNS records on Cloudflare

## Usage example

```terraform
module "my-zone" {
  source = "github.com/UCL-ARC/terraform-cloudflare-arc-dns?ref=v0.0.1"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id

  a_records_yaml     = yamldecode(file("${path.module}/a-records.yaml"))
  cname_records_yaml = yamldecode(file("${path.module}/cname-records.yaml"))
}
```

where `a-records.yaml` is a YAML file with entries representing A records:
```yaml
---
<SUBDOMAIN1>:
  value:       "<ORIGIN_IP1>"
  ttl:         "3600"
  proxy:       false
  owner_email: email@example.com
<SUBDOMAIN2>:
  value: "<ORIGIN_IP2>"
  owner_email: email@example.com
```
which would result in the creation of `<SUBDOMAIN1>.<DOMAIN>` and `<SUBDOMAIN2>.<DOMAIN>`.

- `<SUBDOMAIN1>` would be a traditional A record pointing at `<ORIGIN_IP1>` with a TTL of 1 hour.
- `<SUBDOMAIN2>` would be an A record pointing at `<ORIGIN_IP2>` but proxied through Cloudflare, i.e., the origin IP would not be exposed. The TTL is automatically handled by Cloudflare when proxied.

`cname-records.yaml` contains the CNAME records to create:
```yaml
---
<SUBDOMAIN3>:
  value: "<DEST_HOSTNAME>"
  owner_email: email@example.com
```
which will create a CNAME record for `<SUBDOMAIN3>.<DOMAIN>` pointing to `<DEST_HOSTNAME>`. By default this is proxied through Cloudflare.


----

## Contributing

- Fork this repository and create a branch.
- Use the `[issue-type]-[issue-number]-[issue-title]` branching convention and favour short-lived branches.
- Raise Pull Requests (PR) against `main` for review.
- The person approving the review is responsible for merging and deleting the
  branch.
