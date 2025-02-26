# Create a bucket
gcloud storage buckets create gs://i27gcsexample

# Describe the bucket
gcloud storage buckets describe gs://i27gcsexample/

# Update the bucket with a predefined acl
gcloud storage buckets update gs://i27gcsexample/ --predefined-default-object-acl=publicRead

# Upload the objects to the bucket
gsutil cp index* gs://i27gcsexample/

# List the objects in the bucket
gsutil ls gs://i27gcsexample/


# Verify the acl of the objects
gsutil acl get gs://i27gcsexample/index.html

#----------------------------------------------- Object Level ACL -----------------------------------------------
# Create a bucket
gsutil mb gs://i27gcsexample-object-acl

# Upload the objects to the bucket
gsutil cp index* gs://i27gcsexample-object-acl/

# List the objects in the bucket
gsutil ls gs://i27gcsexample-object-acl/

# Set the acl of the object
gcloud storage object update gs://i27gcsexample-object-acl/index.html --predefined-acl=publicRead # this will set the acl of the specific object to publicRead


# Delete the object
gsutil rm gs://i27gcsexample-object-acl/index.html

# Delete the bucket
gsutil rm -r gs://i27gcsexample-object-acl
gssutil rm -r gs://i27gcsexample

#----------------------------------------------- Uniform ACL -----------------------------------------------
