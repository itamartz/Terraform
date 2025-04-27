module "droplet" {
  source               =  "../../modules/droplet"
  server_name          = "splcms"
  digitalocean_ssh_id = "46839414" # doctl compute ssh-key list --format ID,Name --no-header
  server_role          = "cms"
}