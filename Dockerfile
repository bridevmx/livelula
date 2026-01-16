# ==========================================
# ETAPA 1: El "Transportador"
# ==========================================
# Usamos la imagen oficial de Dragonfly solo un segundo para extraer su binario.
# Esto asegura que tenemos la versión correcta y compilada.
FROM docker.dragonflydb.io/dragonflydb/dragonfly:latest as dragonfly-source

# ==========================================
# ETAPA 2: La Imagen Final (Tu Aplicación)
# ==========================================
# Usamos una base de Node.js ligera (Debian Slim)
FROM node:18-slim

# 1. Instalar dependencias mínimas del sistema operativo
# procps es necesario para que el script de inicio pueda gestionar procesos
RUN apt-get update && apt-get install -y \
    ca-certificates \
    procps \
    && rm -rf /var/lib/apt/lists/*

# 2. Configurar el directorio de trabajo
WORKDIR /app

# --- MOMENTO CRÍTICO ---
# 3. Copiar el binario de Dragonfly desde la Etapa 1 a esta imagen
# Lo colocamos en /usr/local/bin para que sea fácil de ejecutar
COPY --from=dragonfly-source /usr/local/bin/dragonfly /usr/local/bin/dragonfly

# 4. Instalar dependencias de Node.js
COPY package*.json ./
# Instalamos solo lo necesario para producción para ahorrar espacio
RUN npm ci --omit=dev

# 5. Copiar el resto del código de tu aplicación
COPY . .

# 6. Copiar el script de arranque y hacerlo ejecutable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 7. Exponer el puerto donde escucha Fastify (informativo para Shiper)
EXPOSE 3000

# 8. Comando maestro que inicia todo
CMD ["/start.sh"]