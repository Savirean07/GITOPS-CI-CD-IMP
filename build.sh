#!/bin/bash
set -e

echo "Building Node.js application..."

# Install dependencies
npm install

# Install ESLint for code quality checks
echo "Installing ESLint..."
npm install eslint --save-dev

echo "Build complete!"
