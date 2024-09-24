FROM node:18-slim

WORKDIR /app

COPY package.json ./
COPY pnpm-lock.yaml ./
RUN corepack enable --install-directory=/usr/bin \
    && corepack prepare --activate pnpm@latest
RUN npm install -g pnpm 
RUN pnpm install --force
COPY . .
RUN pnpm run build
RUN rm -rf node_modules
RUN pnpm install --force --prod

# runtime image
FROM node:18-alpine

ENV TZ="Asia/Shanghai"

WORKDIR /app
COPY package.json .
COPY public /app/public
COPY config /app/config
COPY --from=0 /app/node_modules /app/node_modules
COPY --from=0 /app/dist /app/dist

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
