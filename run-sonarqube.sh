#!/bin/bash

echo "Starting SonarQube Scan..."

sonar-scanner \
  -Dsonar.projectKey=gitops-project \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000

echo "SonarQube Scan Completed!"
