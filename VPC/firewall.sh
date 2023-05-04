# Create a custom-vpc
gcloud compute networks create custom-network --subnet-mode=custom
echo "Network Created Succefsully........"

# Create Subnet-a in custom-vpc
# N/w name, cidr range, region
gcloud compute networks subnets create subnet-a --network custom-network --region us-central1 --range 10.2.1.0/24
echo "Subnet-a Created Succesfully......."

# Create subnet-b in custom-vpc
gcloud compute networks subnets create subnet-b --network custom-network --region us-central1 --range 10.2.2.0/24
echo "Subnet-b Created Succesfully......."

# Create instance-1a in subnet-a
gcloud compute instances create instance-1a --zone us-central1-a --subnet=subnet-a --machine-type=f1-micro

# Create instance-1b in subnet-a
gcloud compute instances create instance-1b --zone us-central1-a --subnet=subnet-a --machine-type=f1-micro --no-address

# Create instance-1c in subnet-a
gcloud compute instances create instance-1c --zone us-central1-a --subnet=subnet-a --machine-type=f1-micro

# Create instance-2 in subnet-b
gcloud compute instances create instance-2 --zone us-central1-a --subnet=subnet-b --machine-type=f1-micro

# Create instance-3 in subnet-b
gcloud compute instances create instance-3 --zone us-central1-a --subnet=subnet-b --machine-type=f1-micro --no-address
