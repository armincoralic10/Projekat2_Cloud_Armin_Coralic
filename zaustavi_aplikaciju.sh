#!/bin/bash
echo "==> Zaustavljam sve kontejnere aplikacije... "

docker compose stop

echo "==> Aplikacija je zaustavljena. Podaci su sačuvani u volumenima. "