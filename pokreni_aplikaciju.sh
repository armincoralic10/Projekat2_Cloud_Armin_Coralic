#!/bin/bash
echo "==> Pokrećem sve servise aplikacije..."

docker compose up -d

echo "==> Aplikacija je uspješno pokrenuta! [cite: 51]"
echo "==> Možete joj pristupiti na: http://localhost:3000 [cite: 53]"