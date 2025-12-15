# Creation automatique des utilisateurs sous linux


## Parties
- **part0** : Procedure de modification du serveur ssh
- **part1** : Script Bash 
- **part2** : Ansible complet
- **part3** : Terraform exécutant le script Bash

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
