
variable "digitalocean_ssh_id" {
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

## Volume variables
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

variable "droplet_image" {
  description = "Image for the droplet"
  type        = string
  default     = "centos-stream-9-x64" # "ubuntu-24-04-x64"
}

variable "droplet_size" {
  description = "Size of the droplet"
  type        = string
  default     = "s-4vcpu-8gb"
}

variable "droplet_tags" {
  description = "Tags for the droplet"
  type        = set(string)
  default     = null
}


## Tailscale variables
variable "tailscale_auth_key" {
  description = "Tailscale auth key"
  type        = string
  default     = "null"
}

## DNS variables
variable "domain_name" {
  description = "Domain name for the droplet"
  type        = string
  default     = "0546746147.com"
}

variable "server_record_ttl" {
  description = "TTL for the Splunk record"
  type        = number
  default     = 3600
}

## Splunk variables
variable "splunk_admin_password" {
  description = "splunk admin password"
  type        = string
  default     = "1c43b41b-65e4-4325-9717-8a62bbc28b2e"
}

variable "server_role" {
  type        = string
  description = "Splunk Role"
  validation {
    condition     = contains(["cms", "idx", "shc","bastion"], var.server_role)
    error_message = "server_role must be one of: cms, idx, shc, bastion."
  }
}