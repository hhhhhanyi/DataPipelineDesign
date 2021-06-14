#!/bin/bash
# not stop if error
set +e

. ./utilities.sh

TABLE_SETTING=$(cat tableConfig.json | sed -r 's|//.*$||g')
echo "$TABLE_SETTING" | jq -r '.[] | [.TABLE_NAME, .DATASET_ID, .CLUSTER_FIELDS, .PARTITION_FIELDS ] | @tsv' | \
while IFS=$'\t' read -r TABLE_NAME DATASET_ID CLUSTER_FIELDS PARTITION_FIELDS ; do
    i=$(($i + 1))
    echo "$i: $DATASET_ID $TABLE_NAME"    
    createTable "true"
done
