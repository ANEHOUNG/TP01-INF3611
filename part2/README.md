# Partie 2 - Ansible

Playbook Ansible complet et idempotent pour créer les utilisateurs.

### Fichiers
- `create_users.yml` : Playbook principal
- `process_user.yml` : Tâches incluses pour le traitement par utilisateur
- `templates/welcome.txt.j2` : Template du message de bienvenue
- `inventory.ini` : Exemple d'inventaire
- `users.txt` : Exemple

### Utilisation
1. Adapter `inventory.ini` avec l’IP de ton serveur Ubuntu
2. Placer ton `users.txt` dans le dossier
3. Exécuter depuis la machine de contrôle (où Ansible est installé) :
   ```bash
   ansible-playbook -i inventory.ini create_users.yml -e "group_name_var=students-inf-361"
