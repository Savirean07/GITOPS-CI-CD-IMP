#!/bin/bash

# This script runs the OWASP Dependency-Check tool.
# It will download the tool automatically if not found.

set -e # Exit immediately if a command exits with a non-zero status.

echo "Running OWASP Dependency Check..."

# --- Setup Dependency-Check --- 
DC_VERSION="9.2.0" # You can update this version as needed
DC_DIR="dependency-check"

if [ ! -d "$DC_DIR" ]; then
  echo "Dependency-Check not found. Downloading version ${DC_VERSION}..."
  wget "https://github.com/jeremylong/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip"
  unzip "dependency-check-${DC_VERSION}-release.zip"
  rm "dependency-check-${DC_VERSION}-release.zip"
else
  echo "Dependency-Check already installed."
fi

DC_EXECUTABLE="${DC_DIR}/bin/dependency-check.sh"

# --- Run the scan ---
echo "Starting OWASP scan..."
"${DC_EXECUTABLE}" \
  --project "GITOPS-CI-CD-IMP" \
  --scan . \
  --format "ALL" \
  --out ./owasp-report \
  --disableYarnAudit \
  --nvdApiKey "${NVD_API_KEY}"

echo "OWASP Scan complete. Report saved to ./owasp-report"
