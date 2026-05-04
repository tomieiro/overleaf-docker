#!/bin/sh
set -e

which node
if command -v grunt >/dev/null 2>&1 && [ -f /var/www/sharelatex/Gruntfile.js ]; then
  which grunt
  ls -al /var/www/sharelatex/migrations
  cd /var/www/sharelatex && grunt migrate -v
else
  echo "Skipping legacy grunt migrations"
fi
echo "All migrations finished"
