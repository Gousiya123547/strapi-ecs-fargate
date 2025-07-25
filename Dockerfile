# Stage 1: Build Strapi
FROM node:18-bullseye as build

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
  python3 \
  make \
  g++ \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Production Image
FROM node:18-bullseye

WORKDIR /app
COPY --from=build /app /app

# Expose Strapi's default port
EXPOSE 1337

CMD ["npm", "start"]

