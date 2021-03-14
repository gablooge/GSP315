#!/bin/bash
gcloud auth revoke --all

while [[ -z "$(gcloud config get-value core/account)" ]]; 
do echo "waiting login" && sleep 2; 
done

while [[ -z "$(gcloud config get-value project)" ]]; 
do echo "waiting project" && sleep 2; 
done

gcloud config set compute/zone us-east1-b

export PROJECT_ID=$(gcloud info --format='value(config.project)')
gsutil mb -l us-east1 gs://$PROJECT_ID

gcloud pubsub topics create memtopic

export LASTUSER=$(gcloud projects get-iam-policy $PROJECT_ID --flatten="bindings[].members" --format='table(bindings.members)' --filter="bindings.members:user:student*" |& tail -1)

gcloud projects remove-iam-policy-binding $PROJECT_ID --member $LASTUSER --role roles/viewer

cd thumbnail-nodejs/ 

gcloud functions deploy thumbnail --region=us-east1 --trigger-bucket=gs://$PROJECT_ID --runtime=nodejs8 --entry-point=thumbnail  --quiet

cd ..
gsutil cp map.jpg gs://$PROJECT_ID/



