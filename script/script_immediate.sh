#!/bin/bash

#Usage:         ./script_immediate.sh domain
#ex:            ./script_immediate.sh ndd.fr

#nom du domaine
#ex: ndd.fr
SITE=$1
DATE=$(date "+%d-%m-%Y")
#Login compte OVH
LOGIN=username # voir pour le recupérer via des variables environnement
#Mot de passe compte OVH
PASSWORD=password # voir pour le recupérer via des variables environnement
#Dossier de stockage
DOSSIER=/var/www/logs/
DOSSIERGOACCESS=/var/www/
FILENAME=immediate
#Numéro du cluster ovh https://logs.XXXXXXX.hosting.ovh.net/
CLUSTER=cluster005
#Creation de url pour récupérer les statistiques
LOGS='https://logs.'$CLUSTER'.hosting.ovh.net/'$SITE'/osl'
#Creation du dossier LOG
mkdir -p $DOSSIER
mkdir -p $DOSSIERGOACCESS
# Téléchargement du log
CURRENTLOG=$DOSSIER$SITE-$DATE.log
wget -nv -nd -R A.gz -P$DOSSIER $LOGS/$SITE-$DATE.log --http-user=$LOGIN --http-password=$PASSWORD -o $DOSSIER/logs-wget.txt
# Traitement dans goaccess
goaccess $CURRENTLOG --log-format=COMBINED -o $DOSSIERGOACCESS$FILENAME.html
rm -rf $DOSSIER