##### Required Variables #####

variable "proxmox_host" {
  type        = string
  description = "The Proxmox host or IP address."
}

variable "proxmox_username" {
  type        = string
  description = "Username when authenticating to Proxmox, including the realm."
  sensitive   = true
}

variable "proxmox_password" {
  type        = string
  description = "Password for the user."
  sensitive   = true
}

variable "disk_storage_pool" {
  type        = string
  description = "Storage pool for the boot disk and cloud-init image."
}

variable "disk_storage_pool_type" {
  type        = string
  description = "Storage pool type for the boot disk and cloud-init image."
}

##### Optional Variables #####

variable "proxmox_port" {
  type        = number
  description = "The Proxmox port."
  default     = 8006
}

variable "proxmox_skip_verify_tls" {
  type        = bool
  description = "Skip validating the Proxmox certificate."
  default     = true
}

variable "proxmox_node" {
  type        = string 
  description = "Which node in the Proxmox cluster to start the virtual machine on during creation."
  default     = "proxmox"
}

variable "template_name" {
  type        = string
  description = "The VM template name."
  default     = "ubuntu-20.04-base" 
}

variable "template_description" {
  type        = string
  description = "Description of the VM template."
  default     = "Base template for Ubuntu 20.04" 
}

variable "template_vm_id" {
  type        = number
  description = "The ID used to reference the virtual machine. This will also be the ID of the final template. If not given, the next free ID on the node will be used."
  default     = null
}

variable "ssh_username" {
  type        = string
  description = "The username to connect to SSH with." 
  default     = "packer"
}

variable "ssh_password" {
  type        = string
  description = "A plaintext password to use to authenticate with SSH."
  default     = "packer"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to private key file for SSH authentication."
  default     = null 
}

variable "ssh_public_key" {
  type        = string
  description = "Public key data for SSH authentication. If set, password authentication will be disabled."
  default     = null
}

variable "ssh_agent_auth" {
  type        = bool
  description = "Whether to use an exisiting ssh-agent to pass in the SSH private key passphrase."
  default     = false
}

variable "memory" {
  type        = number
  description = "How much memory, in megabytes, to give the virtual machine."
  default     = 1024
}

variable "cores" {
  type        = number
  description = "How many CPU cores to give the virtual machine."
  default     = 1
}

variable "sockets" {
  type        = number
  description = "How many CPU sockets to give the virtual machine."
  default     = 1
}

variable "iso_url" {
  type        = string
  description = "URL to an ISO file to upload to Proxmox, and then boot from."
  default     = "https://releases.ubuntu.com/20.04/ubuntu-20.04.1-live-server-amd64.iso"
}

variable "iso_storage_pool" {
  type        = string
  description = "Proxmox storage pool onto which to find or upload the ISO file."
  default     = "local"
}

variable "iso_file" {
  type        = string
  description = "Filename of the ISO file to boot from."
  default     = null //"ubuntu-20.04.1-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "Checksum of the ISO file."
  default     = null
}

variable "http_bind_address" {
  type        = string
  description = "This is the bind address for the HTTP server. Defaults to 0.0.0.0 so that it will work with any network interface."
  default     = null
}

variable "http_interface" {
  type        = string
  description = "Name of the network interface that Packer gets HTTPIP from."
  default     = null
}

variable "vm_interface" {
  type        = string
  description = "Name of the network interface that Packer gets the VMs IP from." 
  default     = null
}

variable "cloud_init_storage_pool" {
  type        = string
  description = "Name of the Proxmox storage pool to store the Cloud-Init CDROM on. If not given, the storage pool of the boot device will be used (disk_storage_pool)."
  default     = null
}

variable "cloud_init_apt_packages" {
  type        = list(string)
  description = "A list of apt packages to install during the subiquity cloud-init installer."
  default     = []
}

variable "locale" {
  type        = string
  description = "The system locale set during the subiquity install."
  default     = "en_US" 
}

variable "keyboard_layout" {
  type        = string
  description = "Sets the keyboard layout during the subiquity install."
  default     = "en" 
}

variable "keyboard_variant" {
  type        = string
  description = "Sets the keyboard variant during the subiquity install."
  default     = "us" 
}

variable "timezone" {
  type        = string
  description = "Sets the timezone during the subiquity install."
  default     = "Etc/UTC" 
}