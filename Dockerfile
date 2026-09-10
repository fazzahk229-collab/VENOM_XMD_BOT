# — Build stage —
FROM node:20-bookworm-slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# — Runtime stage —
FROM node:20-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist

# Persist auth + media across container restarts via volumes.
VOLUME ["/app/sessions", "/app/media", "/app/logs"]

CMD ["node", "dist/index.js"]
