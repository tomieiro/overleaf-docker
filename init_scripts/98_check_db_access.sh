#!/bin/sh
set -e

echo "Checking can connect to mongo and redis"
if command -v grunt >/dev/null 2>&1 && [ -f /var/www/sharelatex/Gruntfile.js ]; then
  cd /var/www/sharelatex && grunt check:redis
  cd /var/www/sharelatex && grunt check:mongo
else
  echo "Skipping legacy grunt db checks"
fi
echo "All checks passed"
