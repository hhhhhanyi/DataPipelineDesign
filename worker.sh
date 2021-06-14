#!/bin/bash
# not stop if error
set +e

. utilities.sh
. workflow.sh

PROJECT_ID=${PROJECT_ID:="alfred-recruitment-test"}

if [[ -z "$FLOW_NAME" ]]; then
    return 0
fi

FILE_NAME="${FLOW_NAME}_${EPOCHSECONDS}"

echo "{ \"FLOW_NAME\": \"start $FLOW_NAME\", \"DATE\": \"`date "+%Y-%m-%d %H:%M:%S.%s"`\"}"

FLOW_INFO=$(cat workflow/$FLOW_NAME.json | sed -r 's|//.*$||g')
for flowStep in $(echo $FLOW_INFO | jq -r '.[] | @base64'); do
    stepName=$(getFlowStepInfo $flowStep "stepName")
    stepMethod=$(getFlowStepInfo $flowStep "stepMethod")
    echo "--> $stepName [$stepMethod]"
    
    # step start
    $(echo "$stepMethod" "$flowStep")
done

echo "{ \"FLOW_NAME\": \"end $FLOW_NAME\", \"DATE\": \"`date "+%Y-%m-%d %H:%M:%S.%s"`\"}"