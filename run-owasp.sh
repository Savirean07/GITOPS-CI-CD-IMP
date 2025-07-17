#!/bin/bash
set -e

echo "Running OWASP Dependency Check..."

# Run the scan
dependency-check --project "MyApp" --scan . --format HTML --out ./owasp-report

echo "OWASP Scan complete. Report saved to ./owasp-report"
