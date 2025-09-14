#!/usr/bin/env bash
#

set -e 

SOURCE_DATA_DIR="/opt/AAT/data"
SYSTEM_DIR="/opt/system"
DATA_DIR="/opt/system/aat-data-$(date +%Y%m%d%H%M%S)"

if [ ! -d "$SYSTEM_DIR" ]; then
  echo "Ordner $SYSTEM_DIR wird erstellt..."
else
  echo "Ordner $SYSTEM_DIR existiert bereits."
fi
mkdir -p "$SYSTEM_DIR/.old"
cd "$SYSTEM_DIR/"
for dir in aat-data-*; do
  [ -d "$dir" ] && mv "$dir" .old/
done
cd .old
ls -dt aat-data-* 2>/dev/null | tail -n +11 | xargs -r rm -rf
if [ ! -d "$DATA_DIR" ]; then
  echo "Ordner $DATA_DIR wird erstellt..."
  mkdir -p "$DATA_DIR"
else
  echo "Ordner $DATA_DIR existiert bereits."
fi
echo "Verschieben von Dateien und Ordnern aus $SOURCE_DATA_DIR nach $DATA_DIR..."
if [ -d "$SOURCE_DATA_DIR" ]; then
  cp -rf "$SOURCE_DATA_DIR"/* "$DATA_DIR"/
  echo "Alle Dateien und Ordner wurden erfolgreich verschoben (überschrieben, falls vorhanden)."
else
  echo "Quellordner $SOURCE_DATA_DIR existiert nicht. Bitte überprüfen."
  exit 1
fi
