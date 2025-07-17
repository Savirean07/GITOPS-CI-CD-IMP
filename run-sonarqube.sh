#!/bin/bash

echo "Running SonarQube analysis..."

# Run the SonarQube scanner using the token for authentication
sonar-scanner \
  -Dsonar.projectKey=gitops-ci-cd \
  -Dsonar.sources=. \
  -Dsonar.host.url=${SONAR_HOST_URL} \
  -Dsonar.login=${SONAR_TOKEN}

echo "SonarQube Scan Completed!"
