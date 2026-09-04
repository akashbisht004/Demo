# ---------- Client ----------
FROM node:22-alpine AS client-build

WORKDIR /app/client

COPY client/package*.json ./
RUN npm ci

COPY client/ .
RUN npm run build


# ---------- Server ----------
FROM node:22-alpine AS server-build

WORKDIR /app/server

COPY server/package*.json ./
RUN npm ci

COPY server/ .

RUN npm run build

# ---------- Production ----------
FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY --from=server-build /app/server/package*.json ./server/
COPY --from=server-build /app/server/node_modules ./server/node_modules
COPY --from=server-build /app/server/dist ./server/dist

COPY --from=client-build /app/client/dist ./client/dist

WORKDIR /app/server

EXPOSE 3000

CMD ["node", "dist/index.js"]