Procédure de modification du serveur SSH
1. Procédure correcte (étapes)
1.	Sauvegarder la configuration courante :
 	sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%F_%T)
2.	Éditer le fichier de configuration en utilisant un éditeur sécurisé (vim/nano) :
 	sudo nano /etc/ssh/sshd_config
3.	Appliquer les modifications en testant (optionnel) :
o	Vérifier la syntaxe (OpenSSH ne fournit pas de commande syntax-check dédiée; on teste en lançant un sshd supplémentaire sur un port de test) :
 	sudo sshd -t || echo "sshd config OK"
o	Ou démarrer une seconde instance test :
 	sudo /usr/sbin/sshd -f /etc/ssh/sshd_config -p 2222
4.	Redémarrer ou recharger le service ssh :
 	sudo systemctl reload sshd    # conserve connexions
 ou
sudo systemctl restart sshd   # arrête et relance
5.	Vérifier l’état et les logs :
 	sudo systemctl status sshd
sudo journalctl -u sshd --since "5 minutes ago"
6.	Tester une connexion depuis une session distante (idéalement avant de fermer votre session actuelle) :
 	ssh -p <port> user@server_ip
2. Principal risque si la procédure n’est pas respectée
•	Se verrouiller hors du serveur (lockout) : modification d’un paramètre critique (ex : changement de port sans mise à jour du pare-feu, désactivation des clés publiques, restriction des authentifications) peut empêcher toute nouvelle connexion. D’où l’importance de garder la session active pendant le test et d’avoir une sauvegarde de la configuration.
3. Cinq paramètres SSH à durcir (avec justification)
•	PermitRootLogin no — Empêche la connexion directe du compte root ; réduit la surface d’attaque.
•	PasswordAuthentication no (si possible) — Force l’usage des clés publiques, beaucoup plus sûr que les mots de passe.
•	Port 22 → personnaliser (ex: Port 2222) — Réduit le bruit des scans automatiques (sécurité par l’obscurité, faible mais utile en complément).
•	AllowUsers / AllowGroups — Restreint qui peut se connecter via SSH.
•	PermitEmptyPasswords no — Empêche connexions avec mots de passe vides.
