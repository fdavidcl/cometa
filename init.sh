#!/bin/bash
IFS='
'

function process_dataset {
    local dataset="$1"
    local name="${dataset##*/}"
    local basename="${name%.*}"

    bin/metadata "$dataset" public/ || exit 1
    cp public/json/"$basename".json site/_data/datasets 
    bin/format $dataset public/full/ || exit 1
    mkdir -p public/partitions/"$name"
    # Pretty slow:
    bin/partition "$dataset" public/partitions/"$name" || exit 1
    bin/compress public/partitions/"$name" public/partitions || exit 1
    rm -rf public/partitions/"$name"
    bin/link public/full site/datasets_rds.csv "https://cometa.ujaen.es/public/full" || exit 1
    bin/generate site app
    
    rm "$dataset"
}

function process_loop {
    # Set watch
    inotifywait -e moved_to -e create public/pending
    local names=($(ls -1 public/pending/*.rds 2> /dev/null))
    echo "New datasets: $names"

    while [[ "${#names[@]}" -gt 0 ]]; do
        #echo "${names[0]}"
        #rm "${names[0]}"
        local current="${names[0]}"
        echo "Now processing: $current"
        process_dataset "$current"
        names=($(ls public/pending/*.rds 2> /dev/null))
    done
}

function main {
    mkdir -p public/{pending,full,partitions,json,img}

    bin/generate site app
    bin/serve app &

    while true; do
        process_loop
    done
}

# cd /usr/app
if [[ -d public ]]; then
    main
else
    echo "A bind mount with target /usr/app/public is needed"
    exit -2
fi
