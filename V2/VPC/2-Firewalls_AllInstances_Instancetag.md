
# Google Cloud VPC, Subnets, Instances, and Firewall Creation Guide

This guide outlines the steps for creating a custom VPC, subnets, instances, and firewalls on Google Cloud Platform.

## What will be created:

- **Custom VPC:** A virtual private cloud in custom mode.
- **Subnets:** Two subnets (subnet-a and subnet-b) in the custom VPC.
- **Instances:** Five instances in total across the two subnets.
  - Three instances in `subnet-a`, one of which has no external IP, and one tagged to deny ping.
  - Two instances in `subnet-b`, one tagged to allow ping, and one with no external IP.
- **Firewall Rules:**
  - A firewall rule to allow SSH access.
  - A firewall rule to allow ICMP (ping) between internal subnets.
  - A firewall rule to deny ping from instance-1c to instance-2 using **network tags**.

## Creation Script:

```bash
# Create a custom VPC
gcloud compute networks create custom-network --subnet-mode=custom
echo "Network Created Successfully........"

# Create Subnet-a in custom VPC
gcloud compute networks subnets create subnet-a --network custom-network --region us-central1 --range 10.2.1.0/24
echo "Subnet-a Created Successfully......."

# Create Subnet-b in custom VPC
gcloud compute networks subnets create subnet-b --network custom-network --region us-central1 --range 10.2.2.0/24
echo "Subnet-b Created Successfully......."

# Create instance-1a in subnet-a
gcloud compute instances create instance-1a --zone us-central1-a --subnet=subnet-a --machine-type=e2-medium

# Create instance-1b in subnet-a (without external IP)
gcloud compute instances create instance-1b --zone us-central1-a --subnet=subnet-a --machine-type=e2-medium --no-address

# Create instance-1c in subnet-a with tag deny-ping
gcloud compute instances create instance-1c --zone us-central1-a --subnet=subnet-a --machine-type=e2-medium --tags=deny-ping

# Create instance-2 in subnet-b with tag allow-ping
gcloud compute instances create instance-2 --zone us-central1-a --subnet=subnet-b --machine-type=e2-medium --tags=allow-ping

# Create instance-3 in subnet-b (without external IP)
gcloud compute instances create instance-3 --zone us-central1-a --subnet=subnet-b --machine-type=e2-medium --no-address

# Create a firewall rule to allow SSH access
echo "Creating a firewall for SSH"
gcloud compute firewall-rules create allow-ssh-custom-nw --direction=INGRESS --priority=1000 --network=custom-network --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0

# Create a firewall rule to allow internal ICMP (ping) between subnets
echo "Creating a firewall to allow internal ping between subnets"
gcloud compute firewall-rules create allow-icmp-custom-internal --direction=INGRESS --priority=1000 --network=custom-network --action=ALLOW --rules=icmp --source-ranges=10.2.1.0/24

# Create a firewall rule to deny instance-1c from pinging instance-2 using network tags
echo "Creating a firewall to deny instance-1c from pinging instance-2"
gcloud compute firewall-rules create deny-instance-1c --direction=INGRESS --priority=1000 --network=custom-network --action=DENY --rules=icmp --source-tags=deny-ping --target-tags=allow-ping
```

## Deletion Script:

```bash
# Delete the firewall rules
echo "Deleting firewall rules..."
gcloud compute firewall-rules delete allow-ssh-custom-nw --quiet
gcloud compute firewall-rules delete allow-icmp-custom-internal --quiet
gcloud compute firewall-rules delete deny-instance-1c --quiet

# Delete the instances
echo "Deleting instances..."
gcloud compute instances delete instance-1a --zone=us-central1-a --quiet
gcloud compute instances delete instance-1b --zone=us-central1-a --quiet
gcloud compute instances delete instance-1c --zone=us-central1-a --quiet
gcloud compute instances delete instance-2 --zone=us-central1-a --quiet
gcloud compute instances delete instance-3 --zone=us-central1-a --quiet

# Delete the subnets
echo "Deleting subnets..."
gcloud compute networks subnets delete subnet-a --region=us-central1 --quiet
gcloud compute networks subnets delete subnet-b --region=us-central1 --quiet

# Delete the custom VPC
echo "Deleting the VPC network..."
gcloud compute networks delete custom-network --quiet
```
