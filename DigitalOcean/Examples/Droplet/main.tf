module "digitalocean_droplet_splcms" {
  source               =  "../../modules/droplet"
  server_name          = "splcms"
  digitalocean_ssh_id = "46839414" # doctl compute ssh-key list --format ID,Name --no-header
  server_role          = "cms"
}
output "digitalocean_droplet_splcms" {
  value = module.digitalocean_droplet_splcms.*
}