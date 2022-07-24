#!/usr/bin/bash

HOSTNAME=$(cat /etc/hostname)
KIBANA_FILE=kibana-8.3.2-amd64.deb

curl 127.0.0.1:9200 > /dev/null 2>&1
KIBANA_STATUS=$?

if [[ $KIBANA_STATUS -ne 0 ]]; then
  echo ">>> Check if kibana is installed"

  sudo systemctl status kibana > /dev/null 2>&1
  IS_KIBANA_EXIST=$?

  if [[ $IS_KIBANA_EXIST -ne 0 ]]; then
    echo ">>> Installing kibana"

    if [ ! -f "$PWD/$KIBANA_FILE" ]; then
      echo ">>> Download file"
      wget -q "https://artifacts.elastic.co/downloads/kibana/$KIBANA_FILE"
    fi

    if [ ! -f "$PWD/$KIBANA_FILE.sha512" ]; then
      echo ">>> Download sha file"
      wget -q "https://artifacts.elastic.co/downloads/kibana/$KIBANA_FILE.sha512"
    fi

    shasum -a 512 -c "$KIBANA_FILE.sha512" > /dev/null 2>&1
    SHA_STATUS=$?

    if [[ $SHA_STATUS -eq 0 ]]; then
      sudo dpkg -i "$KIBANA_FILE"
      
      echo ">>> Generate elastic Token"
      /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

      echo ">>> Autostart kibana at boot"
      sudo systemctl daemon-reload && sudo systemctl enable kibana
      echo ">>> Starting kibana"
      sudo systemctl start kibana
    fi

    rm ./"$KIBANA_FILE" ./"$KIBANA_FILE.sha512"
  else
    echo ">>> Starting kibana"
    sudo systemctl start kibana
  fi
else
  echo ">>> kibana is already running"
fi