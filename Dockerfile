FROM node:18-alpine AS base 

FROM base AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN  yarn install --production && yarn cache clean
COPY . .
CMD ["node", "src/index.js"]
EXPOSE 3000 