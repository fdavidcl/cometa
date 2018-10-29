#!/bin/bash

function generate_pages {
    bundle exec jekyll build -s site -d app
}

function process_dataset {
    local dataset=$1

    bin/metadata $dataset public/
    bin/format $dataset public/full/
    mkdir -p public/partitions/$dataset
    # Pretty slow:
    bin/partition $dataset public/partitions/$dataset
    bin/compress public/partitions/$dataset public/partitions
    bin/link public/full site/datasets.csv "https://cometa.ujaen.es/public/full"
    generate_pages
    
    rm $dataset
}

function process_loop {
    # Set watch
    inotifywait -e moved_to -e create public/pending
    local names=($(ls public/pending/*.rds 2> /dev/null))
    echo "New datasets: $names"

    while [[ "${#names[@]}" -gt 0 ]]; do
        #echo "${names[0]}"
        #rm "${names[0]}"
        process_dataset public/pending/"${names[1]}"
        names=($(ls public/pending/*.rds 2> /dev/null))
    done
}

function main {
    mkdir -p public/{pending,full,partitions,json,img}
    
    #bin/serve app

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
