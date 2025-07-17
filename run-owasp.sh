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
DC_ARGS="--project GITOPS-CI-CD-IMP --scan . --format ALL --out ./owasp-report --disableYarnAudit"

# Only add the NVD API key if the environment variable is set
if [ -n "$NVD_API_KEY" ]; then
  DC_ARGS="$DC_ARGS --nvdApiKey \"$NVD_API_KEY\""
else
  echo "NVD_API_KEY not set. Running scan without it. This may result in errors or long scan times."
fi

echo "Starting OWASP scan..."
eval "\"${DC_EXECUTABLE}\" $DC_ARGS"

echo "OWASP Scan complete. Report saved to ./owasp-report"
