#!/bin/bash

set -e

echo "Running OWASP Dependency Check..."

echo "Installing project dependencies..."
npm install

DC_VERSION="9.2.0"
DC_DIR="dependency-check"

if [ ! -d "$DC_DIR" ]; then
  echo "Dependency-Check not found. Downloading version ${DC_VERSION}..."
  wget "https://github.com/jeremylong/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip"
  unzip "dependency-check-${DC_VERSION}-release.zip"
  mv "dependency-check-${DC_VERSION}" "$DC_DIR"
  rm "dependency-check-${DC_VERSION}-release.zip"
else
  echo "Dependency-Check already exists."
fi

DC_EXECUTABLE="${DC_DIR}/bin/dependency-check.sh"

mkdir -p odc-data
DC_ARGS="--project GITOPS-CI-CD-IMP --scan . --format ALL --out ./owasp-report --data ./odc-data --disableYarnAudit --enableExperimental --disableArchive"

if [ -n "$NVD_API_KEY" ]; then
  DC_ARGS="$DC_ARGS --nvdApiKey $NVD_API_KEY"
else
  echo "⚠️ NVD_API_KEY not set. Running without it may cause errors or slow scans."
fi

echo "Starting OWASP scan..."
bash "$DC_EXECUTABLE" $DC_ARGS

echo "OWASP Scan complete. Report is in ./owasp-report"
