# Create Users Automation - 3 méthodes d'automatisation

Ce dépôt regroupe **3 approches différentes** pour automatiser la création massive d'utilisateurs sur un serveur Ubuntu, en respectant exactement les contraintes du sujet.

## Parties

- **part1-bash** : Script Bash pur
- **part2-ansible** : Playbook Ansible complet
- **part3-terraform** : Infrastructure as Code avec Terraform exécutant le script Bash

Toutes les parties créent :
- Un groupe passé en paramètre (ex: `students-inf-361`)
- Les utilisateurs à partir de `users.txt` (format : `username;password;full_name;phone;email;shell`)
- Shell préféré (installation si besoin, fallback `/bin/bash`)
- Ajout au groupe + sudo
- Interdiction de `su` pour le groupe
- Message de bienvenue personnalisé
- Limites mémoire (20 % RAM)
- Quotas disque (15 Go)
- Logs complets
- Email personnalisé (Ansible uniquement)

Bon déploiement !
