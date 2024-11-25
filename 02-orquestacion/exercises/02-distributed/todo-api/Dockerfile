FROM node:22-alpine AS builder

WORKDIR /build

# Copy backend app files
COPY ./src ./src

# Copy dependencies manifest
COPY package*.json ./

# Copy compile configuration
COPY tsconfig.json ./ 

# Build app
RUN npm ci

RUN npm run build

# Packaging app
FROM node:22-alpine AS app

WORKDIR /app

COPY --from=builder ./build/wwwroot ./

# Install production dependencies
COPY package*.json ./

RUN npm ci --only=production

CMD [ "node", "app.js" ]
