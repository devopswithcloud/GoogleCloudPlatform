### gcloud commands to create a network , subnet and 3 virtual machines 
* gcloud compute networks create custom-network --subnet-mode custom

* gcloud compute networks subnets create subnet-a --network=custom-network --region=us-central1 --range=10.2.1.0/24

* gcloud compute networks subnets create subnet-b --network=custom-network --region=us-central1 --range=10.2.2.0/24

* gcloud compute instances create instance-1a --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-a 

* gcloud compute instances create instance-1b --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-a --no-address

* gcloud compute instances create instance-1c --zone=us-central1-a--machine-type=f1-micro --subnet=subnet-a

* gcloud compute instances create instance-2 --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-b

* gcloud compute instances create instance-3 --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-b --no-address

