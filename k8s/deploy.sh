#!/bin/bash

kubectl create secret generic gcloud-credential --from-file=gcloud-credential.json
kubectl apply -f DeviceConnectionReport.cronjob.yml