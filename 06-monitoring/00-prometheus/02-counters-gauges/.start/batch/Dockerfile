FROM node:16-alpine 

WORKDIR /opt/app

COPY . .

RUN npm ci 

CMD ["npm", "start"]