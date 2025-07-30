# Use Node.js base image
FROM node:18

# Create app directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the app port (adjust if different)
EXPOSE 3000

# Start the app (adjust if needed)
CMD ["node", "index.js"]
