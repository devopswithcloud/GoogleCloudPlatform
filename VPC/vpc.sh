# These are
# https://cloud.google.com/sdk/docs/quickstarts
# https://cloud.google.com/sdk/docs/components

$ lscpu
$ free -m
$ lsblk
$ cat /etc/*release*

$ mkdir /opt/batch10 # this is ephemeral, means it will be gone after the restart of the shell

# Where is cloud shell provisioned ??
# https://www.google.com/about/datacenters/


gcloud init
gcloud info
gcloud version
gcloud auth list
gcloud config list


gcloud auth login
gcloud auth revoke

gcloud projects list

gcloud compute instances create gcloudinstance



#https://cloud.google.com/sdk/gcloud/reference/config/configurations/create
gcloud config list
gcloud config get-value project
gcloud config set project <PROJECT_ID>
gcloud config set compute/zone us-east1
gcloud config unset compute/zone

gcloud config configurations list
gcloud config configurations create prod --no-activate

gcloud config list --configuration dev-data

gcloud components list

# Working with API's
gcloud services -h
gcloud services list -h
gcloud services list --available
gcloud services list --enabled
gcloud services enable compute.googleapis.com
gcloud services list --available | grep compute


#Get your Cloud project ID by running the following command:
gcloud config get-value project
