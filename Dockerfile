# NOMBRE DEL ARCHIVO: Dockerfile
# ------------------------------

# Descargar la imagen YA LISTA desde tu registro de GitHub
# IMPORTANTE: Cambia 'bridevmx' si tu usuario es diferente
FROM ghcr.io/bridevmx/livelula:latest

# Exponer puerto
EXPOSE 3000

# Arrancar
CMD ["/start.sh"]