#!/bin/bash
set -e # Detener el script si algo falla

echo "--- Iniciando despliegue en Shiper con DragonflyDB ---"

# 1. Iniciar DragonflyDB en segundo plano (& al final)
# IMPORTANTE:
# --maxmemory=64mb: Le damos solo 64MB. Dejamos ~180MB para Node.js.
# Si subes esto, tu contenedor podría morir por falta de RAM.
# --bind localhost: Solo escucha dentro del contenedor por seguridad.
echo "Iniciando DragonflyDB (Límite estricto: 64MB)..."
/usr/local/bin/dragonfly --maxmemory=64mb --cache_mode=true --bind localhost &

# Esperamos 3 segundos para asegurar que Dragonfly esté listo para recibir conexiones
sleep 3

# 2. Iniciar tu servidor Fastify
echo "Dragonfly listo. Iniciando Fastify..."
# Usamos 'exec' para que Node pase a ser el proceso principal
exec node server.js