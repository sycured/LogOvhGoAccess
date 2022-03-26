#!/bin/bash

#Usage:         ./script_daily.sh domain
#ex:            ./script_daily.sh ndd.fr


#Date de la veille
DATE=$(date --date=yesterday "+%d-%m-%Y")
#Mois
MONTH=$(date --date=yesterday "+%m-%Y")
#nom du domaine
#ex: ndd.fr
SITE=$1
#Login compte OVH
LOGIN=username # voir pour le recupérer via des variables environnement
#Mot de passe compte OVH
PASSWORD=password # voir pour le recupérer via des variables environnement
#Dossier de stockage
DOSSIER=/var/www/logs/
DOSSIERGOACCESS=/var/www/
#Numéro du cluster ovh https://logs.XXXXXXX.hosting.ovh.net/
CLUSTER=cluster005
#Creation de url pour récupérer les statistiques
LOGS='https://logs.'$CLUSTER'.hosting.ovh.net/'$SITE'/logs'
#Creation du dossier LOG
mkdir -p $DOSSIER
mkdir -p $DOSSIERGOACCESS
# Téléchargement du log
CURRENTLOG=$DOSSIER$SITE-$DATE.log.gz
wget -nv -nd -R A.gz -P$DOSSIER $LOGS/logs-$MONTH/$SITE-$DATE.log.gz --http-user=$LOGIN --http-password=$PASSWORD -o $DOSSIER/logs-wget.txt
# Traitement dans goaccess
zcat -f $CURRENTLOG | goaccess --log-format=COMBINED -o $DOSSIERGOACCESS$DATE.html
rm -rf $DOSSIER


# Génération du fichier de listing des archives
INDEX=index.html
echo "<html>" >$DOSSIERGOACCESS$INDEX
echo "<head>" >> $DOSSIERGOACCESS$INDEX
echo "<title>Statistique du site $SITE</title>" >> $DOSSIERGOACCESS$INDEX
echo "</head>" >> $DOSSIERGOACCESS$INDEX
echo "<body>" >> $DOSSIERGOACCESS$INDEX
echo "<h1>Statistique du site $SITE</h1>" >> $DOSSIERGOACCESS$INDEX
for i in $(ls $DOSSIERGOACCESS);
do 
    echo "<p><a href=\""$i"\">$i</a></p>"   >> $DOSSIERGOACCESS$INDEX
done
echo "</body>" >> $DOSSIERGOACCESS$INDEX
echo "</html>" >> $DOSSIERGOACCESS$INDEX