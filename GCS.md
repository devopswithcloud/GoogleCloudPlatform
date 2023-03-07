## We will create gsutil commands to execute GCS 

### Gstuil command structure
gsutil <command> <options> 
gsutil <command> <options> <source> <target> 

### Create a Multi regional bucket
gsutil mb -c multi_regional -l asia gs://smooth-kiln-376817-multi

gsutil mb -l asia gs://$DEVSHELL_PROJECT_ID-multi-new

### Create a Regional Bucket
gsutil mb -c regional -l us-central1 gs://$DEVSHELL_PROJECT_ID-regional
  
### Remove a bucket 
gsutil rb gs://$DEVSHELL_PROJECT_ID-multi-new
  
### Create a Nearline bucket with multi regional 
gsutil mb -c nearline -l asia gs://$DEVSHELL_PROJECT_ID-nearline-multi-regional
 
### List bukcets
gsutil ls 

### Create a coldine

### Create a archive 
  
### Copy a object from local to bucket
gsutil cp source destination
gsutil cp logfile0603.txt gs://smooth-kiln-376817-multi/

### Copy a object from bucket to local
gsutil cp source destination
gsutil cp gs://smooth-kiln-376817-multi/logfile0603.txt .
  
### Copy objects from one bucket to other bucket
gsutil cp source destination
gsutil cp gs://smooth-kiln-376817-multi/logfile0603.txt gs://smooth-kiln-376817-regional/
  
### List the objects available in the bucket 
gsutil ls <bucketname>
gsutil ls gs://smooth-kiln-376817-multi/
  
### Create a Service account using CLI
gcloud iam service-accounts create instancestorage --display-name="Instance to storage"

### Create a key for the service account account created 
gcloud iam service-accounts keys create key.json --iam-account=instancestorage@smooth-kiln-376817.iam.gserviceaccount.com 

### Add service account storage viewer role
gcloud projects add-iam-policy-binding --member=instancestorage@smooth-kiln-376817.iam.gserviceaccount.com --role=roles/storage.objectViewer

### Set the service account in the VM
gcloud config set account instancestorage@smooth-kiln-376817.iam.gserviceaccount.com
  
## Authenticate the service account into the vm.
gcloud auth activate-service-account instancestorage@smooth-kiln-376817.iam.gserviceaccount.com --key-file=key.json
  
## Verify 
gsutil commands 
