# ==========================================
# ETAPA 1: El "Transportador"
# ==========================================
# 1. Usamos la imagen oficial de Dragonfly para copiar el binario
FROM docker.dragonflydb.io/dragonflydb/dragonfly:latest AS dragonfly-source

# ==========================================
# ETAPA 2: La Imagen Final
# ==========================================
# 2. Usamos Node.js ligero
FROM node:18-slim

# Instalar utilidades básicas del sistema
RUN apt-get update && apt-get install -y \
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# --- PASO CRÍTICO CORREGIDO ---
# Copiamos archivos de dependencias
COPY package*.json ./

# CAMBIO: Usamos 'npm install' en lugar de 'npm ci'
# Esto funcionará aunque no tengas package-lock.json subido
RUN npm install --omit=dev

# Copiamos el binario de Dragonfly desde la Etapa 1
COPY --from=dragonfly-source /usr/local/bin/dragonfly /usr/local/bin/dragonfly

# Copiamos el código y el script de arranque
COPY . .
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000

CMD ["/start.sh"]