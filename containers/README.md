# Lancement ELK par docker

## Prérequis
Pour persister les données de notre stack ELK, on sauvegarde les données sur le poste local. Pour cela, il faut configurer un répertoire de travail :

1. Copier le fichier `.env.default` dans un fichier `.env` (:warning: le fichier doit être en UTF-8 avec un caractère de fin de ligne UNIX (LF))
2. Créer les dossiers de travail :
````shell
WORKING_DIR="/tmp/elk"
source .env
mkdir -p "${WORKING_DIR}/elasticsearch/data"
mkdir -p "${WORKING_DIR}/kibana/data"
mkdir -p ${WORKING_DIR}/nginx/{logs,notice-logs,tools-trace-logs}
````

## Lancement de l'ELK
:warning: A faire au 1er déploiement :warning:
Vous 
````shell
docker-compose up -d
````

## :warning: A faire au 1er déploiement :warning:

### Reset du password elastic
L'utilisateur `elastic` est l'utilisateur administrateur par défaut. Au 1er démarrage, il faudra reset le mot de passe de ce compte comme ceci :
````shell
docker exec -it elasticsearch bin/elasticsearch-reset-password -u elastic
````
Pour choisir un mot de passe à vous, il faudra attendre d'accéder à l'interface Kibana pour accéder à la modification de mot de passe.

* [TODO] Tester elasticsearch via CURL (récupérer certificat)
* 
Au 1er lancement, le conteneur kibana n'arrivera pas à se connecter à elasticsearch. Pour cela vous devez :
1. Générer un token pour le compte de service `elastic/kibana` :
````shell
docker exec elasticsearch bin/elasticsearch-service-tokens create kibana kibana_token
docker exec elasticsearch bin/elasticsearch-create-enrollment-token -s kibana
````
