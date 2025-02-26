# Description: Create a service account in google cloud and add it to the instance

# Set the project id
PROJECT=your-project-id

# Create a svc account in google
gcloud iam service-accounts create instancestorage --display-name="Instance to storage"

# Create a key for the service account
gcloud iam service-accounts keys create instancestorage.json --iam-account=instancestorage@${PROJECT}.iam.gserviceaccount.com

# add storage admin role to the service account
gcloud projects add-iam-policy-binding ${PROJECT} --member=serviceAccount:instancestorage@${PROJECT}.iam.gserviceaccount.com --role=roles/storage.admin

# Set service account to the instance
gcloud config set account instancestorage@${PROJECT}.iam.gserviceaccount.com

# Activate the service account
gcloud auth activate-service-account instancestorage@${PROJECT}.iam.gserviceaccount.com --key-file=instancestorage.json