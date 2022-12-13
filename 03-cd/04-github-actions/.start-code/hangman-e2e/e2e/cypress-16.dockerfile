FROM cypress/base:16

WORKDIR /app

RUN npm init -y 
RUN npm install cypress typescript -D

ENV CI=1

RUN npx cypress verify
