#!/bin/bash
set -e

echo "Running OWASP Dependency Check..."

# --- Find the dependency-check executable ---
# This makes the script more robust by checking common installation paths.
if [ -x "/opt/homebrew/bin/dependency-check.sh" ]; then
  # Path for Apple Silicon Macs
  DC_EXECUTABLE="/opt/homebrew/bin/dependency-check.sh"
elif [ -x "/usr/local/bin/dependency-check.sh" ]; then
  # Path for Intel Macs
  DC_EXECUTABLE="/usr/local/bin/dependency-check.sh"
else
  echo "[ERROR] dependency-check.sh not found."
  echo "Please ensure OWASP Dependency-Check is installed and accessible at /opt/homebrew/bin or /usr/local/bin."
  exit 1
fi

echo "Using Dependency-Check executable at: ${DC_EXECUTABLE}"

# --- Run the scan ---
"${DC_EXECUTABLE}" \
  --project "GITOPS-CI-CD-IMP" \
  --scan . \
  --format "ALL" \
  --out ./owasp-report \
  --disableYarnAudit

echo "OWASP Scan complete. Report saved to ./owasp-report"
