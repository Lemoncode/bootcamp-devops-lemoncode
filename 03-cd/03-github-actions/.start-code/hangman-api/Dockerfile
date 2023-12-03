#------------------------------------------------------------------------------
# -- builder
#------------------------------------------------------------------------------
FROM node:lts-alpine as builder

WORKDIR /app
COPY . .

RUN npm ci
RUN npm run build

#------------------------------------------------------------------------------
# -- app
#------------------------------------------------------------------------------
FROM node:lts-alpine as app

WORKDIR /app
COPY --from=builder /app/dist .
COPY package.json .
COPY package-lock.json .

ENV NODE_ENV=production

RUN npm install


CMD ["npm", "start"]
