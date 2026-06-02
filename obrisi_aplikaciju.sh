#!/bin/bash
echo "==> Započinjem potpuno brisanje projekta... "

docker compose down

echo "==> Brišem volumene..."
docker volume rm db_data || true

echo "==> Brišem mreže..."
docker network rm app_network || true

echo "==> Brišem image-ove..."
docker rmi racunari-backend racunari-frontend || true

echo "==> Sve komponente projekta (kontejneri, volumeni, mreže i image-ovi) su obrisani! "