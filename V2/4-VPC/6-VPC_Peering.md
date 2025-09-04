
# VPC Peering Setup, Conflict Resolution, ICMP Testing, and Cleanup

## Step 1: Infrastructure Creation with ICMP Testing

```bash
#!/bin/bash

# Enable Compute API
echo "Enabling Compute API..."
gcloud services enable compute.googleapis.com


# Create VPC 1
echo "Creating VPC 1 and subnets..."
gcloud compute networks create network-1 --subnet-mode=custom
gcloud compute networks subnets create subnet-1a --network=network-1 --region=us-central1 --range=10.0.1.0/24
gcloud compute networks subnets create subnet-1b --network=network-1 --region=us-central1 --range=10.1.1.0/24

# Create VPC 2
echo "Creating VPC 2 and subnets..."
gcloud compute networks create network-2 --subnet-mode=custom
gcloud compute networks subnets create subnet-2a --network=network-2 --region=us-central1 --range=10.0.2.0/24
gcloud compute networks subnets create subnet-2b --network=network-2 --region=us-central1 --range=10.1.2.0/24
gcloud compute networks subnets create conflict-with-network-1-subnet --network=network-2 --region=us-central1 --range=10.0.1.0/24

# Create VPC 3
echo "Creating VPC 3 and subnets..."
gcloud compute networks create network-3 --subnet-mode=custom
gcloud compute networks subnets create subnet-3a --network=network-3 --region=us-central1 --range=10.0.3.0/24
gcloud compute networks subnets create subnet-3b --network=network-3 --region=us-central1 --range=10.1.3.0/24
gcloud compute networks subnets create conflict-with-network-2-subnet --network=network-3 --region=us-central1 --range=10.0.2.0/24

# Create firewall rules for VPC 1
echo "Creating firewall rules for VPC 1..."
gcloud compute firewall-rules create ssh-allow-network-1 --direction=INGRESS --priority=1000 --network=network-1 --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create icmp-allow-network-1 --direction=INGRESS --priority=1000 --network=network-1 --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0

# Create firewall rules for VPC 2
echo "Creating firewall rules for VPC 2..."
gcloud compute firewall-rules create ssh-allow-network-2 --direction=INGRESS --priority=1000 --network=network-2 --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create icmp-allow-network-2 --direction=INGRESS --priority=1000 --network=network-2 --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0

# Create firewall rules for VPC 3
echo "Creating firewall rules for VPC 3..."
gcloud compute firewall-rules create ssh-allow-network-3 --direction=INGRESS --priority=1000 --network=network-3 --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create icmp-allow-network-3 --direction=INGRESS --priority=1000 --network=network-3 --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0

# Create VM instances
echo "Creating VM instances in each VPC subnet..."
gcloud compute instances create instance-1 --zone=us-central1-a --machine-type=e2-medium --subnet=subnet-1a
gcloud compute instances create instance-2 --zone=us-central1-a --machine-type=e2-medium --subnet=subnet-2a
gcloud compute instances create instance-3 --zone=us-central1-a --machine-type=e2-medium --subnet=subnet-3a

echo "Infrastructure setup complete!"
```

---

## Step 2: Test ICMP Between Instances

1. **SSH into instance-1** from `network-1`:

   ```bash
   gcloud compute ssh instance-1 --zone=us-central1-a
   ```

2. **Ping instance-2** in `network-2` (this will fail because peering is not established):

   ```bash
   ping <instance-2-private-ip>
   ```

3. **Ping instance-3** in `network-3` (this will also fail):

   ```bash
   ping <instance-3-private-ip>
   ```

---

## Step 3: Resolve Conflicts Before VPC Peering

To establish VPC peering, you must first delete the conflicting subnets between the networks:

```bash
# Delete conflicting subnets from network-2 and network-3
gcloud compute networks subnets delete conflict-with-network-1-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete conflict-with-network-2-subnet --region=us-central1 --quiet
```

---

## Step 4: Establish VPC Peering

After deleting the conflicting subnets, you can now establish VPC peering:

```bash
# VPC peering between network-1 and network-2
gcloud compute networks peerings create network-1-to-network-2     --network=network-1     --peer-network=network-2     --auto-create-routes

# VPC peering between network-2 and network-3
gcloud compute networks peerings create network-2-to-network-3     --network=network-2     --peer-network=network-3     --auto-create-routes
```

---

## Step 5: Re-Test ICMP After VPC Peering

1. **SSH into instance-1** again from `network-1`:

   ```bash
   gcloud compute ssh instance-1 --zone=us-central1-a
   ```

2. **Ping instance-2** again, and this time it should succeed:

   ```bash
   ping <instance-2-private-ip>
   ```

3. **Ping instance-3**, and it should work now:

   ```bash
   ping <instance-3-private-ip>
   ```

---

## Step 6: Clean Up the Infrastructure

```bash
#!/bin/bash

# Delete VM instances
echo "Deleting VM instances..."
gcloud compute instances delete instance-1 --zone=us-central1-a --quiet
gcloud compute instances delete instance-2 --zone=us-central1-a --quiet
gcloud compute instances delete instance-3 --zone=us-central1-a --quiet

# Delete firewall rules
echo "Deleting firewall rules..."
gcloud compute firewall-rules delete ssh-allow-network-1 icmp-allow-network-1 --quiet
gcloud compute firewall-rules delete ssh-allow-network-2 icmp-allow-network-2 --quiet
gcloud compute firewall-rules delete ssh-allow-network-3 icmp-allow-network-3 --quiet

# Delete subnets and VPC networks
echo "Deleting subnets and VPCs..."
gcloud compute networks subnets delete subnet-1a subnet-1b --region=us-central1 --quiet
gcloud compute networks subnets delete subnet-2a subnet-2b --region=us-central1 --quiet
gcloud compute networks subnets delete subnet-3a subnet-3b --region=us-central1 --quiet

gcloud compute networks delete network-1 --quiet
gcloud compute networks delete network-2 --quiet
gcloud compute networks delete network-3 --quiet

echo "Infrastructure cleanup complete!"
```

---

## Summary

1. **Infrastructure Creation**: Creates VPCs, subnets, firewall rules, and VM instances. Initial ICMP test fails due to no VPC peering.
2. **Conflict Resolution**: Deletes conflicting subnets before establishing VPC peering.
3. **VPC Peering**: Sets up VPC peering between networks. ICMP test passes after peering is established.
4. **Cleanup**: Deletes the VMs, firewall rules, subnets, and VPCs.

