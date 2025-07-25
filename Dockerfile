FROM node:18-bullseye

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
  python3 \
  make \
  g++ \
  && rm -rf /var/lib/apt/lists/*

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 1337
CMD ["npm", "start"]

