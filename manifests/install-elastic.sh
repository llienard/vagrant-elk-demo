#!/usr/bin/bash

HOSTNAME=$(cat /etc/hostname)
ELASTIC_FILE=elasticsearch-8.3.2-amd64.deb
ELASTIC_PORT=9200

curl 127.0.0.1:9200 > /dev/null 2>&1
ELASTIC_STATUS=$?

if [[ $ELASTIC_STATUS -ne 0 ]]; then
  echo ">>> Check if Elasticsearch is installed"

  sudo systemctl status elasticsearch > /dev/null 2>&1
  IS_ELASTIC_EXIST=$?

  if [[ $IS_ELASTIC_EXIST -ne 0 ]]; then
    echo ">>> Installing Elasticsearch"

    if [ ! -f "$PWD/$ELASTIC_FILE" ]; then
      echo ">>> Download file"
      wget -q "https://artifacts.elastic.co/downloads/elasticsearch/$ELASTIC_FILE"
    fi

    if [ ! -f "$PWD/$ELASTIC_FILE.sha512" ]; then
      echo ">>> Download sha file"
      wget -q "https://artifacts.elastic.co/downloads/elasticsearch/$ELASTIC_FILE.sha512"
    fi

    shasum -a 512 -c "$ELASTIC_FILE.sha512" > /dev/null 2>&1
    SHA_STATUS=$?

    if [[ $SHA_STATUS -eq 0 ]]; then
      sudo dpkg -i "$ELASTIC_FILE"
      echo ">>> Autostart Elasticsearch at boot"
      sudo systemctl daemon-reload && sudo systemctl enable elasticsearch
      echo ">>> Starting Elasticsearch"
      sudo systemctl start elasticsearch
    fi

    rm ./"$ELASTIC_FILE" ./"$ELASTIC_FILE.sha512"
  else
    echo ">>> Starting Elasticsearch"
    sudo systemctl start elasticsearch
  fi
else
  echo ">>> Elasticsearch is already running"
fi