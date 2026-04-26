#!/bin/bash
set -e

echo "=== Importando scripts generales en torquelab ==="

find /imports -type f -name "*.sql" ! -path "/imports/dataset-meteo/*" | sort | while read -r file; do
    echo "Ejecutando en torquelab: $file"
    psql -U "$POSTGRES_USER" -d "torquelab" -f "$file"
done

echo "=== Importando scripts de dataset-meteo en PracticasSM ==="

find /imports/dataset-meteo -type f -name "*.sql" | sort | while read -r file; do
    echo "Ejecutando en PracticasSM : $file"
    psql -U "$POSTGRES_USER" -d "PracticasSM" -f "$file"
done

echo "=== Importación finalizada ==="