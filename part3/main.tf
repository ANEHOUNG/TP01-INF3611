terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "null" {}

locals {
  connection = {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(pathexpand(var.ssh_private_key))
    host        = var.server_ip
    timeout     = "2m"
  }
}

# Copier le script et users.txt
resource "null_resource" "copy_files" {
  triggers = {
    script_hash = filemd5("create_users.sh")
    users_hash  = filemd5("users.txt")
    group_name  = var.group_name
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(pathexpand(var.ssh_private_key))
    host        = var.server_ip
  }

  provisioner "file" {
    source      = "create_users.sh"
    destination = "/tmp/create_users.sh"
  }

  provisioner "file" {
    source      = "users.txt"
    destination = "/tmp/users.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create_users.sh"
    ]
  }
}

# Exécuter le script
resource "null_resource" "run_script" {
  depends_on = [null_resource.copy_files]

  triggers = {
    script_hash = filemd5("create_users.sh")
    users_hash  = filemd5("users.txt")
    group_name  = var.group_name
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(pathexpand(var.ssh_private_key))
    host        = var.server_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /tmp/create_users.sh ${var.group_name}"
    ]
  }

  # Nettoyage optionnel
  #provisioner "remote-exec" {
    #when = destroy
    #inline = [
     # "rm -f /tmp/create_users.sh /tmp/users.txt"
    #]
  #}
}
