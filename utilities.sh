#!/bin/bash
set +e

gcloudAuth() {
    if [[ "$GAUTH" -eq 1 ]]; then
        return 0
    fi

    gcloud auth activate-service-account --key-file=secret/application_credentials.json
    # checkError "gcloud Auth" "$@"
    gcloud config set project "$PROJECT_ID"
    GAUTH=1
}

getFlowStepInfo () {
    local flowStepInfo=$1
    local infoKey=$2

    echo "$flowStepInfo" | base64 -d | jq -r ".$infoKey"
}

createTable() {
    local recreateTargetTable=${1:-"false"}
    local datasetId=${2:-$DATASET_ID}
    local tableId=${3:-$TABLE_NAME}
    local schemaId=${4:-$TABLE_NAME}
    local schemaOption=${5:-$SCHEMA_OPTION}
    local partitionFields=$PARTITION_FIELDS
    local clusterFields=$CLUSTER_FIELDS

    gcloudAuth

    # check if table exists
    bq --project_id "$PROJECT_ID" show $targetdatasetId.$targettableId
    local notFoundTable=$?

    if [[ $notFoundTable -eq 0 && $recreateTargetTable == "false" ]]; then
        echo "$datasetId.$tableId already exists"
        return 0
    elif [[ $notFoundTable -eq 0 && $recreateTargetTable == "true" ]]; then 
        echo "remove table $datasetId.$tableId"
        bq --project_id $PROJECT_ID rm -f $datasetId.$tableId
    fi

    # gen schema option
    if [[ -n "$partitionFields" ]]; then
        schemaOption="--time_partitioning_field $partitionFields"
    fi
    if [[ -n "$clusterFields" ]]; then
        schemaOption="$schemaOption --clustering_fields $clusterFields"
    fi

    echo "make table $datasetId.$tableId"
    bq --project_id $PROJECT_ID mk \
        --schema workflow/schema/$schemaId.schema.json \
        $schemaOption \
        $datasetId.$tableId
}