#!/bin/bash

REPO_DIR="/opt/AAT"
REPO_URL="https://github.com/NiklasJavier/AAT.git"
DATA_SUBPATH="data"

cd "$REPO_DIR" || exit 1

git fetch "$REPO_URL" main

LOCAL=$(git rev-parse HEAD)       
REMOTE=$(git rev-parse FETCH_HEAD)

if [ "$LOCAL" != "$REMOTE" ]; then
  echo "Änderungen erkannt. Pull wird ausgeführt..."
  git pull "$REPO_URL" main

  CHANGED_FILES=$(git diff --name-only "$LOCAL" HEAD)

  if echo "$CHANGED_FILES" | grep -qE "^${DATA_SUBPATH}/"; then
    echo "Dateien haben sich geändert. Führe weiteres Skript aus..."
    cd /opt/AAT/scripts
    find . -type f -name "*.sh" -exec chmod +x {} \; &&
    /opt/AAT/scripts/tools/transfer-data.sh
  else
    echo "Keine Änderungen im Ordner '$DATA_SUBPATH'."
  fi

else
  echo "Keine Änderungen."
fi
