FROM node:18-bullseye

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Build Strapi admin panel
RUN npm run build

# Expose Strapi default port
EXPOSE 1337

# Start Strapi
CMD ["npm", "start"]

