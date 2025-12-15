variable "server_ip" {
  description = "IP du serveur Ubuntu Server"
  type        = string
}

variable "ssh_user" {
  description = "Utilisateur SSH (root ou utilisateur avec sudo)"
  type        = string
  default     = "root"
}

variable "ssh_private_key" {
  description = "Chemin vers la clé privée SSH"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "group_name" {
  description = "Nom du groupe (ex: students-inf-361)"
  type        = string
  default     = "students-inf-361"
}
