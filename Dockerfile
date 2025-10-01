# stage 1: BUILD (Install dependencies)
# Usar una versión LTS específica para builds determinísticos
# Mantenemos esta en -slim por velocidad de npm install
FROM node:20-slim AS builder

WORKDIR /app
COPY package*.json ./

# Instalar dependencias
RUN npm install

# stage 2: PRODUCTION (Final Hardened Image - ¡Cambiamos a Alpine!)
# Alpine ofrece la mínima superficie de ataque.
FROM node:18-alpine

# 1. ACTUALIZACIÓN CRÍTICA DE SEGURIDAD (Adaptada a Alpine - usa 'apk'):
#    - 'update' (actualiza los repositorios)
#    - 'upgrade' (Aplica parches de seguridad/vulnerabilidades)
#    - 'add' (para instalar 'curl', si es necesario)
#    - 'rm -rf' (limpieza)
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# 2. Creación y asignación de un usuario no-root (Principio de Mínimo Privilegio)
# El comando para crear usuarios en Alpine es distinto.
RUN adduser -D -u 1001 nodejs_user

WORKDIR /app
# Copiar solamente los artefactos necesarios (código y dependencias instaladas)
COPY --from=builder /app /app

# Usar el usuario de bajo privilegio para ejecutar la aplicación
USER nodejs_user

EXPOSE 3000
CMD ["node", "server.js"]