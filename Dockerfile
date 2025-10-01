# stage 1: Build (intall dependences)
FROM node:18-alpine AS builder

RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./

RUN npm install

# stage 2: final image
FROM node:18-slim

# 1. Create user with down permissions
RUN adduser --system --uid 1001 nodejs_use

WORKDIR /app
COPY --from=builder /app /app

USER nodejs_user

EXPOSE 3000
CMD ["node", "server.js"]
