#!/bin/bash

# Get the short hash of the latest commit to use as the image tag
NEW_TAG=$(git rev-parse --short HEAD)

# Use sed to update the image tag in the Kubernetes deployment manifest.
# The -i '' flag is used for macOS compatibility.
sed -i '' "s|image: .*$|image: your-docker-repo/gitops-app:$NEW_TAG|" k8s/deployment.yaml

# Configure git with a bot user
git config user.name "ci-bot"
git config user.email "ci-bot@example.com"

# Add, commit, and push the updated manifest to the repository.
# The '[skip ci]' in the commit message prevents this commit from triggering another pipeline run.
git add k8s/deployment.yaml
git commit -m "Update image tag to $NEW_TAG [skip ci]"

# You will need to configure your repository to allow the CI/CD system to push to the main branch.
git push origin main
