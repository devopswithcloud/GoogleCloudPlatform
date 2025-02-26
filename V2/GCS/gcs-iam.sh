# Create a bucket
gcloud storage buckets create gs://i27gcsiamexample

# upload the objects to the bucket
gsutil cp index* gs://i27gcsiamexample/

# List the objects in the bucket
gsutil ls gs://i27gcsiamexample/

# View the Policy binding of the bucket
gcloud storage buckets get-iam-policy gs://i27gcsiamexample

#Add a iam policy binding to make the bucket public
gcloud storage buckets add-iam-policy-binding gs://i27gcsiamexample --role roles/storage.objectViewer --member allUsers

# View the Policy binding of the bucket
gcloud storage buckets get-iam-policy gs://i27gcsiamexample


# Delete the objects in the bucket
gsutil rm gs://i27gcsiamexample/index.html

# Delete the bucket
gsutil rm -r gs://i27gcsiamexample

