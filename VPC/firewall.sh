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
gcloud compute instances create instance-1c --zone us-central1-a --subnet=subnet-a --machine-type=f1-micro --tags=deny-ping

# Create instance-2 in subnet-b
gcloud compute instances create instance-2 --zone us-central1-a --subnet=subnet-b --machine-type=f1-micro --tags=allow-ping

# Create instance-3 in subnet-b
gcloud compute instances create instance-3 --zone us-central1-a --subnet=subnet-b --machine-type=f1-micro --no-address

echo "Creating a firewall for SSH"
gcloud compute firewall-rules create allow-ssh-custom-nw --direction=INGRESS --priority=1000 --network=custom-network --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0

echo "Creating a firewall to ping using internal subnets"
gcloud compute  firewall-rules create allow-icmp-custom-internal --direction=INGRESS --priority=1000 --network=custom-network --action=ALLOW --rules=icmp --source-ranges=10.2.1.0/24

echo "Create firewall to deny instance1c to ping instance 2"
gcloud compute  firewall-rules create deny-instance-1c --direction=INGRESS --priority=1000 --network=custom-network --action=DENY --rules=icmp --source-tags=deny-ping --target-tags=allow-ping
