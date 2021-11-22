FROM node:12-alpine3.12 as builder

WORKDIR /build

# Copy backend app files
COPY ./src ./src

# Copy frontend app files
COPY ./frontend ./frontend

# Copy dependencies manifest
COPY package*.json ./

# Copy compile configuration
COPY tsconfig.json ./ 

# Build apps
RUN npm install

RUN cd ./frontend && npm install

RUN npm run build

# Packaging app
FROM node:12-alpine3.12 as app

WORKDIR /app

COPY --from=builder ./build/wwwroot ./

# Install production dependencies
COPY package*.json ./

RUN npm ci --only=production

CMD [ "node", "app.js" ]
