
variable "proxmox_host" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "proxmox_token" {
  type = string
}

variable "proxmox_nodename" {
  type = string
}

variable "proxmox_storage" {
  type = string
}

variable "proxmox_storage_type" {
  type = string
}

variable "talos_version" {
  type    = string
  default = "1.4.4"
}
