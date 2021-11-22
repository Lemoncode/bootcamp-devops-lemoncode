FROM node:12-alpine3.12 as builder

ARG API_HOST

WORKDIR /app

COPY . .

RUN npm i 

RUN npm run build

FROM nginx as frontend

COPY --from=builder /app/dist /usr/share/nginx/html
