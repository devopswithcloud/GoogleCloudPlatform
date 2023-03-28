## gcloud commands

### IAM
```bash
# Create a service account 
gcloud iam service-accounts create instancestorage  --display-name="Instance to Storage"

# Create a Key to Service account
gcloud iam service-accounts keys create key.json --iam-account=<SVC_ACCOUNT_MAIL_ID>

# add storge viewer role to the newly created serviceaccount
gcloud projects add-iam-policy-binding --member=serviceAccount:<SVC_ACCOUNT_MAIL_ID> --role=roles/storage.objectViewer

# Set service account
gcloud config set account <SVC_ACCOUNT_MAIL_ID>

# Authenticate svc account with the key created
gcloud auth activate-service-account <SVC_ACCOUNT_MAIL_ID> --key-file=key.json
```
