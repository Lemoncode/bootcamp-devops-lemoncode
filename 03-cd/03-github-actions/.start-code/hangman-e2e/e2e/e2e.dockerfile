FROM cypress/base:16

WORKDIR /app

COPY package.json .

COPY package-lock.json .

COPY ./test-e2e-infrastructure/e2e/ ./test-e2e-infrastructure/e2e/

ENV CI=1 

RUN npm ci -w @pumpbit-quiz-maker/e2e

WORKDIR /app/test-e2e-infrastructure/e2e

RUN npx cypress verify
