FROM node:22-alpine AS builder

ARG API_HOST

WORKDIR /app

COPY . . 

RUN npm ci 

RUN npm run build 

FROM nginx AS frontend 

COPY --from=builder /app/dist /usr/share/nginx/html 