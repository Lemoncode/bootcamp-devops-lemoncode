FROM node:lts-alpine as build

WORKDIR /opt/build

ARG API_URL={{API_URL}}

COPY ./src ./src

COPY .babelrc .

COPY *.json ./

COPY ./config ./config

RUN npm ci 

RUN npm run build

FROM nginx:1.19.0-alpine as app

COPY nginx.conf /etc/nginx/nginx.conf 

WORKDIR /usr/share/nginx/html
COPY --from=build /opt/build/dist/  .

EXPOSE 8080

COPY ./entry-point.sh /
RUN chmod +x /entry-point.sh
ENTRYPOINT [ "sh", "/entry-point.sh" ] 
CMD [ "nginx", "-g", "daemon off;" ]
