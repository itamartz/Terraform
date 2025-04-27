resource "digitalocean_volume" "volume_1" {
  name                    = "${var.server_name}-volume-1"
  region                  = var.digitalocean_region
  size                    = var.digitalocean_volume_size # in GB
  initial_filesystem_type = var.digitalocean_volume_initial_filesystem_type
  description             = "${var.server_name} volume 1"
}
