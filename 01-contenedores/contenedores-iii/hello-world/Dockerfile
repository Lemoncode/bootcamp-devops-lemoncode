FROM node:10.13-alpine

WORKDIR /app

COPY ["package.json", "package-lock.json", "./"]

RUN npm install

COPY . /app

EXPOSE 3000

CMD [ "node", "server.js" ]