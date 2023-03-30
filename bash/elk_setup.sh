#!/bin/bash

# Installation des paquets nécessaires
apt install gpg tee ufw -y

# Ajout de la clé de signature d'Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

# Ajout du référentiel APT Elasticsearch
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list

# Mise à jour de la liste des paquets
apt update

# Installation d'Elasticsearch, Logstash et Kibana
apt install elasticsearch logstash kibana -y

# Démarrage des services Elasticsearch et Kibana
systemctl start elasticsearch
systemctl start kibana
systemctl start logstash

# Activation des services Elasticsearch et Kibana au démarrage
systemctl enable elasticsearch
systemctl enable kibana
systemctl enable logstash

# Configuration de Logstash pour récupérer les journaux syslog
sudo tee /etc/logstash/conf.d/syslog.conf > /dev/null <<EOF
input {
  file {
    path => "/var/log/syslog"
    start_position => "beginning"
  }
}

filter {
  grok {
    match => { "message" => "%{SYSLOGBASE} %{GREEDYDATA:message}" }
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "syslog-%{+YYYY.MM.dd}"
  }
}
EOF

# Redémarrage du service Logstash pour prendre en compte la configuration
systemctl restart logstash

# Configuration du pare-feu pour Kibana
ufw allow 5601/tcp

# Affichage de l'adresse IP du serveur
ip=$(hostname -I | cut -d' ' -f1)
echo ">> La suite ELK est maintenant accessible à l'adresse : http://$ip:5601/"
echo ">> N'oubliez pas de modifier la configuration de Kibana et ElasticSearch !!"

# Redémarrage du service Kibana pour prendre en compte la configuration
systemctl restart kibana