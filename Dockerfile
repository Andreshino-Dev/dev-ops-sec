# stage 1: Build (intall dependences)
FROM node:latest AS builder

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
