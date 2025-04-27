resource "digitalocean_volume" "volume_1" {
  name                    = "${var.server_name}-volume-1"
  region                  = var.digitalocean_region
  size                    = var.digitalocean_volume_size # in GB
  initial_filesystem_type = var.digitalocean_volume_initial_filesystem_type
  description             = "${var.server_name} volume 1"
}

resource "digitalocean_droplet" "droplet_example" {
  image    = var.droplet_image
  name     = var.server_name
  region   = var.digitalocean_region
  size     = var.droplet_size
  ssh_keys = ["${var.digitalocean_ssh_id}"] #["${var.ssh_key_id}"]
  tags     = var.droplet_tags

  volume_ids = [digitalocean_volume.volume_1.id]
  depends_on = [ digitalocean_volume.volume_1 ]

  user_data = templatefile("${path.module}/user_data.tpl", 
    {
      tailscale_auth_key = var.tailscale_auth_key, 
      splunk_admin_password = var.splunk_admin_password, 
      server_name = var.server_name, 
      volume_filesystem_type = var.digitalocean_volume_initial_filesystem_type, 
      volume_size = var.digitalocean_volume_size
    })
}

data "digitalocean_domain" "domain" {
  name = var.domain_name  
}

resource "digitalocean_record" "record" {
  domain = var.domain_name
  name   = var.server_name
  type   = "A"
  value  = digitalocean_droplet.droplet_example.ipv4_address
  ttl    = var.server_record_ttl
  depends_on = [ digitalocean_droplet.droplet_example ]
}