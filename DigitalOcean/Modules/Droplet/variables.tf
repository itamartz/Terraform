
variable "digitalocean_ssh_key" {
  description = "SSH key to be used for the droplet"
  type        = string
  default     = "default"  
}

variable "digitalocean_region" {
  description = "Region to create the droplet in"
  type        = string
  default     = "nyc3"
}

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "example"
}

variable "digitalocean_volume_size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 100
}

variable "digitalocean_volume_initial_filesystem_type" {
  description = "Initial filesystem type for the volume"
  type        = string
  default     = "ext4"
}

## Tailscale variables
variable "tailscale_auth_key" {
  description = "Tailscale auth key"
  type        = string
  default     = "null"
}


## Splunk variables
variable "splunk_admin_password" {
  description = "splunk admin password"
  type        = string
  default     = "1c43b41b-65e4-4325-9717-8a62bbc28b2e"
}