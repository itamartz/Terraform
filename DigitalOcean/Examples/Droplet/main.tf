## From Environment Variables
variable "tailscale_auth_key" {
  description = "Tailscale auth key for the droplets"
  type        = string
}

locals {
  vms = yamldecode(file("${path.module}/vms.yaml")) 
}

module "digitalocean_droplet_all" {
  source              = "../../modules/droplet"
  for_each            = local.vms
  server_name         = each.key
  digitalocean_ssh_id = each.value["ssh_id"]
  server_role         = each.value["role"]
  droplet_tags        = each.value["tags"]
}
output "digitalocean_droplet_all" {
  value = { for k, v in module.digitalocean_droplet_all : k => v }
}

# module "digitalocean_droplet_splcms" {
#   source              = "../../modules/droplet"
#   server_name         = "splcms"
#   digitalocean_ssh_id = "46839414" # doctl compute ssh-key list --format ID,Name --no-header
#   server_role         = "cms"
#   droplet_tags        = ["splunk", "splcms"]
# }
# output "digitalocean_droplet_splcms" {
#   value = module.digitalocean_droplet_splcms.*
# }

# module "digitalocean_droplet_splidx01" {
#   source              = "../../modules/droplet"
#   server_name         = "splidx01"
#   digitalocean_ssh_id = "46839414" # doctl compute ssh-key list --format ID,Name --no-header
#   server_role         = "cms"
#   droplet_tags        = ["splunk","splidx","splidx01"]
# }
# output "digitalocean_droplet_splidx01" {
#   value = module.digitalocean_droplet_splidx01.*
# }

# module "digitalocean_droplet_splidx02" {
#   source              = "../../modules/droplet"
#   server_name         = "splidx02"
#   digitalocean_ssh_id = "46839414" # doctl compute ssh-key list --format ID,Name --no-header
#   server_role         = "cms"
#   droplet_tags        = ["splunk","splidx","splidx02"]
# }
# output "digitalocean_droplet_splidx02" {
#   value = module.digitalocean_droplet_splidx02.*
# }
