terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

data "digitalocean_droplets" "splidx" {
  filter {
    key    = "tags"
    values = ["splidx"]
  }
}

resource "digitalocean_loadbalancer" "public" {
  name   = "splunk"
  region = "nyc3"
  size_unit = 2

  forwarding_rule {
    entry_port     = 8443
    entry_protocol = "http"

    target_port     = 8000
    target_protocol = "http"
  }

  healthcheck {
    port     = 8000
    protocol = "tcp"
  }

   sticky_sessions {
    type = "cookies"
    cookie_name = "splunk"
    cookie_ttl_seconds = 3600
  }

  droplet_ids = toset(data.digitalocean_droplets.splidx.droplets.*.id)
}

output "loadbalancer" {
  value = digitalocean_loadbalancer.public.*
}

## DNS variables
variable "domain_name" {
  description = "Domain name for the droplet"
  type        = string
  default     = "0546746147.com"
}

data "digitalocean_domain" "domain" {
  name = var.domain_name  
}

resource "digitalocean_record" "lb_record" {
  domain = var.domain_name
  name   = "splunk"
  type   = "A"
  value  = digitalocean_loadbalancer.public.ip
  ttl    = 3600
  depends_on = [ digitalocean_loadbalancer.public ]
}
output "lb_record" {
  value = digitalocean_record.lb_record.fqdn
}