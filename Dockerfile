# stage 1: BUILD (Install dependencies)
# Usar una versión LTS específica para builds determinísticos
FROM node:20-slim AS builder

WORKDIR /app
COPY package*.json ./

# Instalar dependencias
RUN npm install

# stage 2: PRODUCTION (Final Hardened Image)
# Mantener el mismo node:18-slim, pero aseguraremos que esté totalmente parcheado.
FROM node:18-slim

# 1. ACTUALIZACIÓN CRÍTICA DE SEGURIDAD (La Corrección del Reporte de Trivy):
#    - 'update' (descarga la lista)
#    - 'upgrade -y' (Aplica todos los parches de seguridad/vulnerabilidades encontradas por Trivy)
#    - 'autoremove' (Remueve dependencias obsoletas)
#    - Limpieza de cache para minimizar el tamaño de la capa
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# 2. Creación y asignación de un usuario no-root (Principio de Mínimo Privilegio)
RUN adduser --system --uid 1001 nodejs_user

WORKDIR /app
# Copiar solamente los artefactos necesarios (código y dependencias instaladas)
COPY --from=builder /app /app

# Usar el usuario de bajo privilegio para ejecutar la aplicación
USER nodejs_user

EXPOSE 3000
CMD ["node", "server.js"]