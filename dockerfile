# Use official Node.js base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy rest of the application code
COPY . .

# Expose application port (e.g., 3000)
EXPOSE 3000

# Start the app
CMD ["node", "index.js"]