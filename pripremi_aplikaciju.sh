#!/bin/bash
echo "==> Pripremam aplikaciju..."

echo "==> 1. Kreiram potrebne Docker mreže i volumene..."

docker network create app_network || true
docker volume create db_data || true

echo "==> 2. Buildam imageove koji nisu preuzeti sa Docker Huba..."
docker compose build

echo "==> Priprema uspješno završena!"