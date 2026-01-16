#!/bin/bash
set -e

echo "--- ARRANCANDO DRAGONFLY + FASTIFY ---"

# Iniciar Dragonfly limitado a 64MB (Vital para tu VPS de 250MB)
/usr/local/bin/dragonfly --maxmemory=64mb --cache_mode=true --bind localhost &

echo "Esperando a Dragonfly..."
sleep 3

echo "Iniciando Fastify..."
exec node server.js