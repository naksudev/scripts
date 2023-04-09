#!/bin/sh

# Mettre à jour les paquets et les installer
apt-get update
apt-get upgrade

# Installer le paquet Apache
apt-get install apache2

# Activer et démarrer Apache au démarrage
systemctl enable apache2
systemctl start apache2

# Supprimer le fichier de configuration par défaut
rm -R /etc/apache2/sites-enabled/000-default.conf

# Créer le fichier de configuration
server_name=abyss

cat <<EOF >/etc/apache2/sites-available/$server_name.conf
<VirtualHost *:80>
       ServerName $server_name.ml
       ServerAlias www.$server_name.ml $server_name.ml
       DocumentRoot /var/www/$server_name/

       ErrorLog /var/log/$server_name.errors.log
       CustomLog /var/log/$server_name.access.log combined
</VirtualHost>

<Directory /var/www/$server_name/>
       Options -Indexes +FollowSymLinks
       AllowOverride None
       Require all granted
</Directory>
EOF

# Créer le dossier du site web et le fichier index
mkdir /var/www/$server_name/

cat <<EOF >/var/www/$server_name/index.html
<!DOCTYPE html>
<html lang="fr">
    <head>
        <title>$server_name</title>
    </head>
    <body>
        <h1>Bienvenue sur $server_name</h1>
        <p>Pour l'instant, il n'y a rien.</p>
    </body>
</html>
EOF

# Activer la configuration
ln -s /etc/apache2/sites-available/$server_name.conf /etc/apache2/sites-enabled/$server_name.conf

# Recharger Apache
systemctl restart apache2
