#!/bin/bash
# Directly export results if you have access to database

set -e

now=$(date -u --iso-8601=seconds)

echo
echo "## Activating yelandur virtualenv"
source $HOME/.virtualenvs/yelandur/bin/activate

echo
echo "## Exporting results"
FLASK_SECRET_KEY_PROD=xx FLASK_CORS_CLIENT_DOMAIN_PROD=xx python $HOME/yelandur/manage.py -m prod export_results

echo
echo "## Renaming files"
mkdir -p data
rm -rf data/profiles-latest.json
rm -rf data/results-latest.json
mv profiles.json data/profiles-${now}.json
mv results.json data/results-${now}.json
ln -s profiles-${now}.json data/profiles-latest.json
ln -s results-${now}.json data/results-latest.json
