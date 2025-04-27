module "droplet" {
  source               = "../../modules/droplet"
  server_name          = "my-droplet"
  digitalocean_ssh_key = "itamar_ssh_key"
}
