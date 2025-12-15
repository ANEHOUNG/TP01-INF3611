

# Partie 3 - Terraform

Configuration Terraform qui copie et exécute ton script Bash original sur un serveur distant.

### Fichiers
- `main.tf` : Configuration principale
- `variables.tf` : Variables
- `terraform.tfvars.example` : À renommer en `terraform.tfvars` et adapter
- `create_users.sh` : Ton script Bash
- `users.txt` : Exemple

### Utilisation
1. Installer Terraform
2. Renommer `terraform.tfvars.example` → `terraform.tfvars` et remplir :
   - `server_ip`
   - `ssh_user` (root recommandé)
   - `ssh_private_key`
   - `group_name`
3. Exécuter :
   ```bash
   terraform init
   terraform apply
