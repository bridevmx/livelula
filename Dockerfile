# Usamos Node Slim (Debian) que es muy compatible y ligero
FROM node:18-slim

# Instalamos Redis directo del repositorio de Linux (Consume casi 0 RAM al instalar)
RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar dependencias
COPY package*.json ./

# TRUCO: --ignore-scripts evita que algunas librerías compilen cosas nativas, ahorrando CPU/RAM
RUN npm ci --omit=dev --ignore-scripts

COPY . .

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3000

CMD ["/start.sh"]