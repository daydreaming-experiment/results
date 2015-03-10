#!/bin/bash

set -e

if [ $# != 1 ]
then
  echo "Usage: $(basename $0) password"
  exit 1
fi

echo "##"
echo "## Getting results"
echo "##"
echo
wget --http-user=results --http-password=$1 http://exports.daydreaming-the-app.net/profiles-latest.json
wget --http-user=results --http-password=$1 http://exports.daydreaming-the-app.net/results-latest.zip
