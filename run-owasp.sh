#!/bin/bash
set -e

echo "Running OWASP Dependency Check..."

# Run the scan
/opt/homebrew/bin/dependency-check.sh \
  --project "GITOPS-CI-CD-IMP" \
  --scan . \
  --format "ALL" \
  --out ./owasp-report \
  --disableYarnAudit

echo "OWASP Scan complete. Report saved to ./owasp-report"
