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
  default     = null
}

variable "proxmox_token" {
  type        = string
  description = "The Proxmox API token."
  sensitive   = true
  default     = null
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
  default     = "alpine-3-cloudinit"
}

variable "template_description" {
  type        = string
  description = "Description of the VM template."
  default     = "Base template for Alpine 3."
}

variable "template_vm_id" {
  type        = number
  description = "The ID used to reference the virtual machine. This will also be the ID of the final template. If not given, the next free ID on the node will be used."
  default     = null
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

variable "root_password" {
  type        = string
  description = "root password to use during the setup process. A random password will be used if null."
  default     = null
  sensitive   = true
}

variable "disk_storage_pool" {
  type        = string
  description = "Storage pool for the boot disk and cloud-init image."
  default     = "local"

  validation {
    condition     = var.disk_storage_pool != null
    error_message = "The disk storage pool must not be null."
  }
}

variable "disk_size" {
  type        = string
  description = "The size of the OS disk, including a size suffix. The suffix must be 'K', 'M', or 'G'."
  default     = "1G"

  validation {
    condition     = can(regex("^\\d+[GMK]$", var.disk_size))
    error_message = "The disk size is not valid. It must be a number with a size suffix (K, M, G)."
  }
}

variable "disk_format" {
  type        = string
  description = "The format of the file backing the disk."
  default     = "raw"

  validation {
    condition     = contains(["raw", "cow", "qcow", "qed", "qcow2", "vmdk", "cloop"], var.disk_format)
    error_message = "The storage pool type must be either 'raw', 'cow', 'qcow', 'qed', 'qcow2', 'vmdk', or 'cloop'."
  }
}

variable "disk_type" {
  type        = string
  description = "The type of disk device to add."
  default     = "scsi"

  validation {
    condition     = contains(["ide", "sata", "scsi", "virtio"], var.disk_type)
    error_message = "The storage pool type must be either 'ide', 'sata', 'scsi', or 'virtio'."
  }
}

variable "memory" {
  type        = number
  description = "How much memory, in megabytes, to give the virtual machine."
  default     = 512
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
  default     = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-virt-3.21.3-x86_64.iso"
}

variable "iso_storage_pool" {
  type        = string
  description = "Proxmox storage pool onto which to find or upload the ISO file."
  default     = "local"
}

variable "iso_file" {
  type        = string
  description = "Filename of the ISO file to boot from."
  default     = null
}

variable "iso_checksum" {
  type        = string
  description = "Checksum of the ISO file."
  default     = null
}

variable "http_server_host" {
  type        = string
  description = "Overrides packers {{ .HTTPIP }} setting in the boot commands. Useful when running packer in WSL2."
  default     = null
}

variable "http_server_port" {
  type        = number
  description = "The port to serve the http_directory on. Overrides packers {{ .HTTPPort }} setting in the boot commands. Useful when running packer in WSL2."
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

variable "network_bridge" {
  type        = string
  description = "The Proxmox network bridge to use for the network interface."
  default     = "vmbr0"
}

variable "cloud_init_storage_pool" {
  type        = string
  description = "Name of the Proxmox storage pool to store the Cloud-Init CDROM on. If not given, the storage pool of the boot device will be used (disk_storage_pool)."
  default     = null
}

variable "apk_packages" {
  type        = list(string)
  description = "Additional APK packages to install in the base image."
  default     = []
}

variable "use_openssh_pam" {
  type        = string
  description = "Use OpenSSH with PAM support. Will allow locked users to use public key SSH authentication if no password is set."
  default     = false
}

variable "keyboard_layout" {
  type        = string
  description = "Sets the keyboard layout during the setup-alpine install."
  default     = "us"
}

variable "keyboard_variant" {
  type        = string
  description = "Sets the keyboard variant during the setup-alpine install."
  default     = "us"
}

variable "timezone" {
  type        = string
  description = "Sets the timezone during the setup-alpine install."
  default     = "UTC"
}

variable "dns_servers" {
  type        = list(string)
  description = "Sets the DNS servers during the setup-alpine install."
  default     = []

  validation {
    condition     = var.dns_servers != null
    error_message = "The DNS server list must not be null. An empty list is allowed."
  }
}
