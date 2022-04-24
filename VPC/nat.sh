#gcloud commands to create network 
gcloud compute networks create my-custom-network --subnet-mode=custom


# To create a subnet to already created network
gcloud compute networks subnets create subnet-a  --network=my-custom-network --range=10.0.1.0/24 --region=us-central1
gcloud compute networks subnets create subnet-b --network=my-custom-network --range=10.0.2.0/24 --region=us-central1

gcloud compute instances create instance-1a --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-a --no-address
gcloud compute instances create instance-1b --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-a --no-address


# Open Firewall rule for ssh 
gcloud compute  firewall-rules create allow-ssh --direction=INGRESS --priority=1000 --network=my-custom-network --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
