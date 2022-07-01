# These are
# https://cloud.google.com/sdk/docs/quickstarts
# https://cloud.google.com/sdk/docs/components

$ lscpu
$ free -m
$ lsblk
$ cat /etc/*release*

$ mkdir /opt/batch11 # this is ephemeral, means it will be gone after the restart of the shell

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




# Firewall commands
### gcloud commands to create a network , subnet and 3 virtual machines 
* gcloud compute networks create custom-network --subnet--mode custom

* gcloud compute networks subnets create subnet-a --network=custom-network --region=us-central1 --range=10.2.1.0/24

* gcloud compute networks subnets create subnet-b --network=custom-network --region=us-central1 --range=10.2.2.0/24

* gcloud compute instances create instance-1a --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-a 

* gcloud compute instances create instance-1b --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-a --no-address

* gcloud compute instances create instance-1c --zone=us-central1-a--machine-type=f1-micro --subnet=subnet-a

* gcloud compute instances create instance-2 --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-b

* gcloud compute instances create instance-3 --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-b --no-address

