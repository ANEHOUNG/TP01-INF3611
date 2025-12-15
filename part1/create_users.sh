#!/bin/bash

# ===================================================================
# Script: create_users.sh
# Auteur: Grok (adapté à vos besoins)
# Description: Création massive d'utilisateurs à partir de users.txt
# Format users.txt attendu :
# username;default_password;full_name;phone;email;preferred_shell
# Exemple:
# alice;MonMotDePasse123;Alice Dupont;+33612345678;alice.dupont@mail.com;/bin/zsh
#
# Usage: sudo ./create_users.sh students-inf-361
# ===================================================================

set -euo pipefail  # Arrêt immédiat en cas d'erreur, variables non définies, etc.

# Vérification exécution en root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en root (sudo)." >&2; exit 1; fi

# Vérification du paramètre (nom du groupe)
if [[ $# -ne 1 ]]; then
    echo "Usage: sudo $0 <nom_du_groupe>" >&2
    echo "Exemple: sudo $0 students-inf-361" >&2
    exit 1
fi

GROUP_NAME="$1"
USERS_FILE="users.txt"
LOG_FILE="/var/log/create_users_$(date +%Y%m%d_%H%M%S).log"

# Création du fichier de log
echo "=== Début d'exécution du script : $(date) ===" | tee "$LOG_FILE"
echo "Groupe cible : $GROUP_NAME" | tee -a "$LOG_FILE"

# Vérifier que le fichier users.txt existe
if [[ ! -f "$USERS_FILE" ]]; then
    echo "ERREUR: Fichier $USERS_FILE introuvable dans $(pwd)" | tee -a "$LOG_FILE"
    exit 1
fi

# Création du groupe principal s'il n'existe pas
if ! getent group "$GROUP_NAME" > /dev/null 2>&1; then
    groupadd "$GROUP_NAME"
    echo "Groupe $GROUP_NAME créé." | tee -a "$LOG_FILE"
else
    echo "Groupe $GROUP_NAME déjà existant." | tee -a "$LOG_FILE"
fi

# Création du groupe sudo si nécessaire (au cas où
if ! getent group sudo > /dev/null 2>&1; then
    groupadd sudo
    echo "Groupe sudo créé (cas rare sur certaines distros)." | tee -a "$LOG_FILE"
fi

# Lecture ligne par ligne du fichier users.txt
while IFS=';' read -r username password full_name phone email shell || [[ -n "$username" ]]; do

    # Ignorer les lignes vides ou commentaires
    [[ -z "$username" || "$username" =~ ^[[:space:]]*# ]] && continue

    # Nettoyage des espaces
    username=$(echo "$username" | xargs)
    password=$(echo "$password" | xargs)
    full_name=$(echo "$full_name" | xargs)
    phone=$(echo "$phone" | xargs)
    email=$(echo "$email" | xargs)
    shell=$(echo "$shell" | xargs)

    echo "========================================" | tee -a "$LOG_FILE"
    echo "Traitement de l'utilisateur : $username" | tee -a "$LOG_FILE"

    # Vérifier si l'utilisateur existe déjà
    if id "$username" &>/dev/null; then
        echo "Utilisateur $username déjà existant → ignoré." | tee -a "$LOG_FILE"
        continue
    fi

    # Vérifier et installer le shell demandé si nécessaire
    if [[ ! -x "$shell" ]]; then
        echo "Shell $shell non trouvé. Tentative d'installation..." | tee -a "$LOG_FILE"
        shell_name=$(basename "$shell")

        case "$shell_name" in
            zsh)
                apt-get update && apt-get install -y zsh
                ;;
            fish)
                apt-get update && apt-get install -y fish
                ;;
            bash)
                # bash est toujours présent
                ;;
            *)
                echo "Shell $shell_name non géré automatiquement → fallback sur /bin/bash" | tee -a "$LOG_FILE"
                shell="/bin/bash"
                ;;
        esac

        # Vérification finale
        if [[ ! -x "$shell" ]]; then
            echo "Impossible d'installer $shell → utilisation de /bin/bash" | tee -a "$LOG_FILE"
            shell="/bin/bash"
        fi
    fi

    # Hachage SHA-512 du mot de passe
    hashed_password=$(openssl passwd -6 "$password")

    # Création de l'utilisateur
    useradd -m -s "$shell" -c "$full_name|$phone|$email" -G "$GROUP_NAME,sudo" "$username"
    echo "$username:$hashed_password" | chpasswd -e

    # Forcer le changement de mot de passe à la première connexion
    chage -d 0 "$username"

    # Création du fichier WELCOME.txt
    cat > "/home/$username/WELCOME.txt" << EOF
=======================================
   Bienvenue $full_name !
=======================================
Nom d'utilisateur : $username
Téléphone WhatsApp : $phone
Email : $email
Shell : $shell

Votre mot de passe par défaut a été défini.
Vous devez le changer dès votre première connexion.

Bonne session sur le serveur $(hostname) !
Date de création : $(date)
=======================================
EOF

    chown "$username:$username" "/home/$username/WELCOME.txt"

    # Ajout de l'affichage du message dans ~/.bashrc
    echo -e "\n# Message de bienvenue personnalisé" >> "/home/$username/.bashrc"
    echo "cat /home/$username/WELCOME.txt" >> "/home/$username/.bashrc"
    chown "$username:$username" "/home/$username/.bashrc"

    # Quota disque : 15 Go max (15360 Mo en blocs de 1K)
    setfacl -m u:$username:15G "/home/$username" 2>/dev/null || \
        echo "setfacl non disponible, quota non appliqué (installez acl ou configurez quota)" | tee -a "$LOG_FILE"

    # Limitation mémoire via limits.conf (20% de la RAM totale)
    total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    max_ram_kb=$(( total_ram_kb * 20 / 100 ))

    echo "@$GROUP_NAME    soft    as      $max_ram_kb" >> /etc/security/limits.conf
    echo "@$GROUP_NAME    hard    as      $max_ram_kb" >> /etc/security/limits.conf

    echo "Utilisateur $username créé avec succès (shell: $shell)" | tee -a "$LOG_FILE"

done < "$USERS_FILE"

# Interdire la commande su aux membres du groupe students-inf-361 via sudoers
SUDOERS_LINE="%$GROUP_NAME ALL=(ALL:ALL) ALL, !/bin/su, !/usr/bin/su"

if ! grep -qF "$SUDOERS_LINE" /etc/sudoers.d/no-su-for-group 2>/dev/null; then
    echo "$SUDOERS_LINE" > /etc/sudoers.d/no-su-for-group
    chmod 440 /etc/sudoers.d/no-su-for-group
    echo "Interdiction de la commande 'su' pour le groupe $GROUP_NAME configurée." | tee -a "$LOG_FILE"
fi

# Alternative : Restreindre su via permissions (empêche su pour tous sauf un groupe autorisé)
if ! getent group wheel > /dev/null 2>&1; then
    groupadd wheel
    echo "Groupe wheel créé pour autoriser su." | tee -a "$LOG_FILE"
fi
chgrp wheel /bin/su
chmod 4750 /bin/su
echo "Permissions de /bin/su modifiées : exécutable seulement par root et wheel." | tee -a "$LOG_FILE"

# Ajout d'une ligne unique pour la limite mémoire (éviter doublons)
if ! grep -q "@$GROUP_NAME.*as" /etc/security/limits.conf; then
    echo "@$GROUP_NAME    soft    as      $max_ram_kb" >> /etc/security/limits.conf
    echo "@$GROUP_NAME    hard    as      $max_ram_kb" >> /etc/security/limits.conf
fi

echo "=== Fin du script : $(date) ===" | tee -a "$LOG_FILE"
echo "Toutes les opérations sont terminées. Log disponible ici : $LOG_FILE"
echo "Pensez à vérifier les quotas (setfacl ou quota) si besoin de précision."

exit 0
