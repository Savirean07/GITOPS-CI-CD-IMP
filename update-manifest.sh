#!/bin/bash

NEW_TAG=$(git rev-parse --short HEAD)

sed -i "s|image: .*$|image: your-docker-repo/gitops-app:$NEW_TAG|" k8s/deployment.yaml

git config user.name "ci-bot"
git config user.email "ci-bot@example.com"
git add k8s/deployment.yaml
git commit -m "Update image tag to $NEW_TAG"
git push origin main
