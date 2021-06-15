#!/bin/bash

import_bq() {
    local stepInfo=$1
    local targetDatasetId=$(getFlowStepInfo $stepInfo "targetDatasetId")
    local targetTableId=$(getFlowStepInfo $stepInfo "targetTableId")
    local sqlFile=$(getFlowStepInfo $stepInfo "sqlFile")
    local schemaOption=$(getFlowStepInfo $stepInfo "schemaOption")
    # if temp table
    local schemaId=$(echo $targetTableId | sed -r 's|Tmp$||g')

    if [[ -z "$targetDatasetId" || -z "$targetTableId" || -z "$sqlFile" ]]; then
        return 0
    fi

    gcloudAuth
    local sql=$(cat workflow/sql/$sqlFile)
    local replaceParm=$(getFlowStepInfo $stepInfo "sqlReplaceParam")

    echo $replaceParm

    while IFS== read VarName VarValue; do
        VarValue=$(eval echo $VarValue)
        sql=$(echo "$sql" | sed "s|{{"$VarName"}}|$VarValue|g")
    done <<<$(echo $replaceParm | jq -cr '.[]')
    echo "$sql" >data/temp_$stepName.sql

    echo "export bq to ${FILE_NAME}.csv"
    bq query --use_legacy_sql=false \
        --project_id "$PROJECT_ID" \
        --format=csv "$sql" > "data/${FILE_NAME}.csv"

    createTable "true" "$targetDatasetId" "$targetTableId" "$schemaId" "$schemaOption"

    echo "import bq from ${FILE_NAME}.csv"
    bq load --noreplace --skip_leading_rows=1 \
        --source_format=CSV \
        $targetDatasetId.$targetTableId \
        data/${FILE_NAME}.csv \
        workflow/schema/$schemaId.schema.json
}

exec_bq_sql() {
    local stepInfo=$1
    local sourceDatasetId=$(getFlowStepInfo $stepInfo "sourceDatasetId")
    local sourceTableId=$(getFlowStepInfo $stepInfo "sourceTableId")
    local targetDatasetId=$(getFlowStepInfo $stepInfo "targetDatasetId")
    local targetTableId=$(getFlowStepInfo $stepInfo "targetTableId")
    local sqlFile=$(getFlowStepInfo $stepInfo "sqlFile")

    gcloudAuth

    local sql=$(cat workflow/sql/$sqlFile)

    bq --project_id $PROJECT_ID query --use_legacy_sql=false "$sql"
}

trigger_flow() {
    local stepInfo=$1
    local targetFlowName=$(getFlowStepInfo $stepInfo "targetFlowName")
    local triggerCondition=$(getFlowStepInfo $stepInfo "triggerCondition")
    local skip=0

    while IFS== read VarName VarValue; do
        VarName=$(eval echo $VarName)
        VarValue=$(eval echo $VarValue)
        if [[ $VarName -ne $VarValue ]]; then
            skip=1
        fi
    done <<<$(echo $triggerCondition | jq -cr '.[]')

    if [[ $skip -eq 1 ]]; then
        echo "skip step"
        return 0
    fi

    FLOW_NAME=$targetFlowName . worker.sh
}
