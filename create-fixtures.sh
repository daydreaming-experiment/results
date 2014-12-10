#!/bin/bash

set -e

folder=fixtures
profile_ids=${folder}/profile_ids.json
results_base=${folder}/results-

if [ -e $folder ]
then
    echo "'${folder}/' folder already exists, I won't overwrite it."
    echo "(Delete it first.)"
    exit 1
fi

mkdir -p ${folder}

# Export profile ids
echo -n "Exporting profile ids..."
jq '[.profiles[] | .id] | {profile_ids: .}' profiles-latest.json > ${profile_ids}
echo " ok"

# Export results per profile id
echo
for profile_id in $(jq -r '.profile_ids[]' ${profile_ids}); do
    echo -n "Exporting results for profile ${profile_id::5}..."
    jq -c ".results | map(select(.profile_id == \"${profile_id}\")) | {results: .}" results-latest.json > "${results_base}${profile_id}.json"
    echo " ok"
done

echo
echo "All done!"
