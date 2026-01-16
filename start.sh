#!/bin/bash
echo "--- Iniciando Modo Supervivencia (Redis) ---"

# Iniciamos Redis en modo demonio (background)
# maxmemory 50mb: Vital para dejar espacio a Node.js
redis-server --daemonize yes --maxmemory 50mb --maxmemory-policy allkeys-lru

# Esperamos un poco
sleep 2

# Iniciamos Node
echo "Iniciando Fastify..."
exec node server.js