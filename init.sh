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
    
    # Pretty slow:
    if [ "$1" == "unpartitioned" ]; then
        mkdir -p public/partitions/"$name"
        bin/partition "$dataset" public/partitions/"$name" || exit 1
        bin/compress public/partitions/"$name" public/partitions || exit 1
    fi
    rm -rf public/partitions/"$name"
    bin/link public/full site/datasets_rds.csv "https://cometa.ujaen.es/public/full" || exit 1
    
    rm "$dataset"
}

function process {
    local names=($(ls -1 public/pending/"$1"/*.rds 2> /dev/null))
    echo "New datasets: $names"

    while [[ "${#names[@]}" -gt 0 ]]; do
        #echo "${names[0]}"
        #rm "${names[0]}"
        local current="${names[0]}"
        echo -e "\e[1mNow processing: $current\e[m"
        process_dataset "$current" "$1"
        names=($(ls public/pending/"$1"/*.rds 2> /dev/null))
    done
}

function loop {
    while true; do
        # Set watch
        inotifywait -e moved_to -e create public/pending/"$1"
        process "$1"
        bin/generate site app
    done
}

function main {
    bin/generate site app
    bin/serve app &

    loop partitioned &
    loop unpartitioned
}

function welcome {
    clear
    read -r -d '' screen <<END

============================================================
\e[1mWelcome to Cometa\e[m
------------------------------------------------------------
Cometa is able to partition your multilabel datasets as well
as host a web repository containing their partitions and 
other additional information. 

Cometa can automatically partition your datasets for 
cross-validation uses. Should you so desire, Cometa will 
generate partitions for hold-out, 1x10 and 2x5 cross 
validation strategies in a variety of file formats. This 
process could take from minutes to hours depending on the 
number of datasets and their size.

The web repository is served at port 80 of this container.

In order to continue, choose an option below:
============================================================

\e[1m1. Automatic\e[m
   Detect new RDS files in \e[4mpublic/pending/unpartitioned\e[m 
   in order to automatically partition them and generate a web 
   repository.
\e[1m2. Only partitioning\e[m
   Partition all datasets in \e[4mpublic/pending/unpartitioned\e[m
   and exit.
\e[1m3. Only serve website\e[m
   Generates a web repository and serves it.
\e[1m4. \e[31mAdvanced: drop to a terminal\e[m
\e[1m0. Quit\e[m
END
    echo -e "$screen\n"
}

function manage_options {
    read -p'Your option: ' -n1 option
    echo ""

    case $option in
        1)
            main
            ;;
        2)
            process
            ;;
        3)
            # If there are existing datasets, we need to copy their
            # metadata to the template site
            bin/generate site app
            bin/serve app
            ;;
        4)
            bash
            welcome
            manage_options
            ;;
        0|$'\04')
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "\e[31mInvalid option\e[m"
            manage_options
            ;;
    esac
}

# cd /usr/app
if [[ -d public ]]; then
    mkdir -p public/{pending/partitioned,pending/unpartitioned,full,partitions,json,img}
    cp public/json/*.json site/_data/datasets 2>/dev/null
    
    if [ -t 0 ]; then
        welcome
        manage_options
    else
        main
    fi
else
    echo "A bind mount with target /usr/app/public is needed"
    exit -2
fi
