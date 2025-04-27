module "droplet" {
  source               =  "../../modules/droplet"
  server_name          = "splcms"
  digitalocean_ssh_key = "itamar_ssh_key"
  server_role          = "cms"
}