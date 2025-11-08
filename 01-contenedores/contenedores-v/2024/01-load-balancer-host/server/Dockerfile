FROM node:22-alpine

WORKDIR /opt/app

COPY index.js .
COPY package.json .
COPY package-lock.json .

RUN npm install --only=production

EXPOSE 8080

CMD [ "npm", "start" ]