## gcloud commands

### IAM
```bash
# Create a service account 
gcloud iam service-accounts create instancestorage  --display-name="Instance to Storage"

# Create a Key to Service account
gcloud iam service-accounts keys create key.json --iam-account=my-iam-account@my-project.iam.gserviceaccount.com

# add storge viewer role to the newly created serviceaccount
gcloud projects add-iam-policy-binding gcpbatch7-327502 --member=serviceAccount:instancestorage@gcpbatch7-327502.iam.gserviceaccount.com --role=roles/storage.objectViewer

# Set service account
gcloud config set account instancestorage@brilliant-will-309007.iam.gserviceaccount.com

# Authenticate svc account with the key created
gcloud auth activate-service-account instancestorage@gcpbatch7-327502.iam.gserviceaccount.com --key-file=key.json
```
