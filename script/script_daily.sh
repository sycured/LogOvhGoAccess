#!/command/with-contenv bash
#Date de la veille
DATE=$(date --date=yesterday "+%d-%m-%Y")
#Mois
MONTH=$(date --date=yesterday "+%m-%Y")
#nom du domaine
#ex: ndd.fr
SITE=$SITE
#Login compte OVH
LOGIN=$OVH_USER # voir pour le recupérer via des variables environnement
#Mot de passe compte OVH
PASSWORD=$OVH_PASSWORD # voir pour le recupérer via des variables environnement
#Numéro du cluster ovh https://logs.XXXXXXX.hosting.ovh.net/
CLUSTER=$OVH_CLUSTER #cluster005
#Dossier de stockage
DOSSIER=/var/www/logs/
DOSSIERGOACCESS=/var/www/
TMP=/tmp/
LOGS="https://logs.$CLUSTER.hosting.ovh.net/$SITE/osl"
# Téléchargement du log
CURRENTLOG=$DOSSIER$SITE-$DATE.log.gz
wget -nv -nd -R A.gz -P$DOSSIER $LOGS/logs-$MONTH/$SITE-$DATE.log.gz --http-user=$LOGIN --http-password=$PASSWORD -o $DOSSIER/logs-wget.txt
# Traitement dans goaccess
zcat -f $CURRENTLOG | goaccess --log-format=COMBINED -o $DOSSIERGOACCESS$DATE.html
rm -rf $DOSSIER*

# Génération du fichier de listing des archives
INDEX=index.html

cat <<EOF > $TMP$INDEX
<html>
<head>
<title>Statistique du site $SITE</title>
</head>
<body>
<h1>Statistique du site $SITE</h1>
EOF
for i in $DOSSIERGOACCESS*.html;
do 
    echo "<p><a href=\""$i"\">$i</a></p>"   >> $TMP$INDEX
done
cat <<EOF >> $TMP$INDEX
</body>
</html>
EOF
mv $TMP$INDEX $DOSSIERGOACCESS$INDEX