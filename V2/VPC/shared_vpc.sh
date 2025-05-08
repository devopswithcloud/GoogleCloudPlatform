#Create 3 projects dev-shared-project, prod-shared-project, host-shared-project

#To create a host-network vpc
gcloud compute networks create host-network --subnet-mode=custom
echo "********* Host-network created succesfully *******"

# To Create a dev Subnet
gcloud compute networks subnets create dev-subnet --range=10.0.2.0/24 \
--network=host-network --region=us-central1
echo "********* Dev Subnet Created Succesfully ********"

#To Create a Private subnet
gcloud compute networks subnets create private-subnet --range=10.0.3.0/24 \
--network=host-network --region=us-central1
echo "********* Private Subnet Created Succesfully ********"


#To Create a Prod-subnet
gcloud compute networks subnets create prod-subnet --range=10.0.1.0/24 \
--network=host-network --region=us-central1
echo "********* Prod Subnet Created Succesfully ********"
