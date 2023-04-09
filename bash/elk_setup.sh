#!/bin/bash

# Mise à jour des paquets Debian
apt-get update

# Installation de gnupg
apt-get install -y gnupg

# Installation de Java
apt-get install -y openjdk-11-jdk

# Installation d'Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update && apt-get install -y elasticsearch

# Configuration d'Elasticsearch
sed -i 's/#cluster.name: my-application/cluster.name: my-cluster/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#network.host: 192.168.0.1/network.host: localhost/g' /etc/elasticsearch/elasticsearch.yml

# Démarrage d'Elasticsearch
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

# Installation de Logstash
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update && apt-get install -y logstash

# Configuration de Logstash
tee /etc/logstash/conf.d/myconfig.conf <<EOF
input {
  file {
    path => "/var/log/syslog"
    start_position => "beginning"
  }
}

filter {
  grok {
    match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "mylogs-%{+YYYY.MM.dd}"
  }
}
EOF

# Démarrage de Logstash
systemctl enable logstash.service
systemctl start logstash.service

# Installation de Kibana
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update && apt-get install -y kibana

# Configuration de Kibana
sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/g' /etc/kibana/kibana.yml

# Démarrage de Kibana
systemctl enable kibana.service
systemctl start kibana.service

# Finalisation de l'installation
echo "ELK (Elasticsearch, Logstash, Kibana) est maintenant installé et configuré sur votre machine."
echo "Accédez à Kibana en naviguant vers http://localhost:5601 dans votre navigateur web."
