module "droplet" {
  source               = "git::https://github.com/itamartz/Terraform.git?ref=41cc906f0bacfaaf81591ccb01951f9bd5435a7f" #"../../modules/droplet"
#   server_name          = "my-droplet"
#   digitalocean_ssh_key = "itamar_ssh_key"
}