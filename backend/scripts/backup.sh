#!/usr/bin/env bash
# Sauvegarde chiffrée de la base et des fichiers. À lancer chaque nuit (cron) sur le serveur.
# Chiffrement avec age (https://age-encryption.org) : seule la clé PRIVÉE, gardée hors du serveur, peut déchiffrer.
#   age-keygen -o cle-privee.txt      # à garder ailleurs ; copier la ligne « public key » dans AGE_RECIPIENT
#
# Ce script ne supprime jamais d'ancienne sauvegarde : définissez vous-même votre durée de conservation
# (et copiez les fichiers HORS du serveur), pour ne pas perdre de données par erreur.
set -euo pipefail
: "${AGE_RECIPIENT:?définir AGE_RECIPIENT (clé publique age)}"
DEST="${BACKUP_DIR:-/var/backups/tchihali}"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEST"
cd "$(dirname "$0")/.."
docker compose -f docker-compose.prod.yml exec -T db pg_dump -U tchihali tchihali | gzip | age -r "$AGE_RECIPIENT" > "$DEST/db-$STAMP.sql.gz.age"
docker compose -f docker-compose.prod.yml exec -T api tar -C /data -cz files | age -r "$AGE_RECIPIENT" > "$DEST/files-$STAMP.tar.gz.age"
echo "Sauvegarde terminée : $DEST ($STAMP)."
