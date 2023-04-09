#!/bin/sh

# Mettre à jour les paquets et les installer
apt-get update
apt-get upgrade

# Installer le paquet Nginx
apt-get install nginx

# Activer et démarrer Nginx au démarrage
systemctl enable nginx
systemctl start nginx

# Supprimer le fichier de configuration par défaut
rm -R /etc/nginx/sites-enabled/default

# Créer le fichier de configuration
server_name=abyss

cat <<EOF >/etc/nginx/sites-available/$server_name.conf
upstream $server_name {
        ip_hash;
        server 10.0.0.1;
        server 10.0.0.2;
}

server {
        listen          80;
        server_name     $server_name.ml;
        access_log      /var/log/$server_name.access.log;

        location / {
                proxy_pass  http://$server_name;
        }
}
EOF

# Activer la configuration
ln -s /etc/nginx/sites-available/$server_name.conf /etc/nginx/sites-enabled/$server_name.conf

# Vérifier la configuration et recharger Nginx
nginx -t && nginx -s reload