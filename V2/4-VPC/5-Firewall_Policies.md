
# Firewall Policy Example
## Google Cloud VPC, VM, Firewall Configuration , firewall policy and Cleanup

## Step 1: Create Two VPCs with Subnets

### Create VPC1 (`i27-vpc1`) with Subnet1

```bash
# Create VPC1 (custom-mode)
gcloud compute networks create i27-vpc1 \
    --subnet-mode=custom

# Create Subnet1 in VPC1
gcloud compute networks subnets create subnet-1 \
    --network=i27-vpc1 \
    --region=us-central1 \
    --range=10.1.1.0/24
```

### Create VPC2 (`i27-vpc2`) with Subnet2

```bash
# Create VPC2 (custom-mode)
gcloud compute networks create i27-vpc2 \
    --subnet-mode=custom

# Create Subnet2 in VPC2
gcloud compute networks subnets create subnet-2 \
    --network=i27-vpc2 \
    --region=us-central1 \
    --range=10.2.1.0/24
```

---

## Step 2: Create VMs in Each Subnet

### Create a VM in VPC1 (`i27-vpc1`), Subnet1

```bash
# Create VM in VPC1 (i27-vpc1), Subnet1
gcloud compute instances create vm-i27-vpc1 \
    --zone us-central1-a \
    --subnet=subnet-1 \
    --network=i27-vpc1 \
    --machine-type=e2-medium
```

### Create a VM in VPC2 (`i27-vpc2`), Subnet2

```bash
# Create VM in VPC2 (i27-vpc2), Subnet2
gcloud compute instances create vm-i27-vpc2 \
    --zone us-central1-a \
    --subnet=subnet-2 \
    --network=i27-vpc2 \
    --machine-type=e2-medium
```

---

## Step 3: Create Firewall Rules to Allow SSH Access (Port 22)

### Create Firewall Rule in `i27-vpc1` to Allow SSH

```bash
# Create firewall rule in VPC1 (i27-vpc1)
gcloud compute firewall-rules create allow-ssh-vpc1 \
    --network=i27-vpc1 \
    --allow=tcp:22 \
    --direction=INGRESS \
    --source-ranges=0.0.0.0/0 \
    --priority=1000 \
    --description="Allow SSH access on port 22 in VPC1"
```

### Create Firewall Rule in `i27-vpc2` to Allow SSH

```bash
# Create firewall rule in VPC2 (i27-vpc2)
gcloud compute firewall-rules create allow-ssh-vpc2 \
    --network=i27-vpc2 \
    --allow=tcp:22 \
    --direction=INGRESS \
    --source-ranges=0.0.0.0/0 \
    --priority=1000 \
    --description="Allow SSH access on port 22 in VPC2"
```

---

## Step 4: SSH into Each VM, Install Apache, and Set Up a Custom HTML Page

### SSH into `vm-i27-vpc1` and Execute the Following Commands

```bash
# SSH into the VM in VPC1 (i27-vpc1)
gcloud compute ssh vm-i27-vpc1 --zone us-central1-a
```

Once inside the VM:

```bash
# Update the package list
sudo apt update -y

# Install Apache2 web server
sudo apt install apache2 -y

# Remove the default index.html file
sudo rm -rf /var/www/html/index.html

# Create a new custom HTML page with the VM name
echo "Welcome to vm-i27-vpc1" | sudo tee /var/www/html/index.html
```

### SSH into `vm-i27-vpc2` and Execute the Following Commands

```bash
# SSH into the VM in VPC2 (i27-vpc2)
gcloud compute ssh vm-i27-vpc2 --zone us-central1-a
```

Once inside the VM:

```bash
# Update the package list
sudo apt update -y

# Install Apache2 web server
sudo apt install apache2 -y

# Remove the default index.html file
sudo rm -rf /var/www/html/index.html

# Create a new custom HTML page with the VM name
echo "Welcome to vm-i27-vpc2" | sudo tee /var/www/html/index.html
```

---

## Step 5: Create and Configure Firewall Policies

1. **Create Firewall Policy**:
   - Go to **Google Cloud Console** > **VPC Network** > **Firewall Policies**.
   - Create a new **Firewall Policy** that will be applied to both `i27-vpc1` and `i27-vpc2`.

2. **Configure Policy**:
   - After creating the firewall policy, go to **Configure Policy**.
   - Add rules to the firewall policy, such as:
     - **Allow HTTP (port 80)** traffic from any IP (`0.0.0.0/0`).
     - **Allow HTTPS (port 443)** traffic from any IP (`0.0.0.0/0`).

3. **Associate Policy with VPCs**:
   - Associate the created firewall policy with the two VPC networks:
     - **i27-vpc1**
     - **i27-vpc2**

---

## Step 6: Delete All the Infrastructure in One Bash Script

```bash
#!/bin/bash

# Delete VMs
gcloud compute instances delete vm-i27-vpc1 --zone us-central1-a --quiet
gcloud compute instances delete vm-i27-vpc2 --zone us-central1-a --quiet

# Delete the firewall rules (SSH rules only)
gcloud compute firewall-rules delete allow-ssh-vpc1 --quiet
gcloud compute firewall-rules delete allow-ssh-vpc2 --quiet

# Delete the subnets and VPCs
gcloud compute networks subnets delete subnet-1 --region=us-central1 --quiet
gcloud compute networks subnets delete subnet-2 --region=us-central1 --quiet
gcloud compute networks delete i27-vpc1 --quiet
gcloud compute networks delete i27-vpc2 --quiet
```

---

## Step 7: Delete Firewall Policy

1. **Remove Association from VPC Networks**:
   - Go to **Google Cloud Console** > **VPC Network** > **Firewall Policies**.
   - Locate your firewall policy and click on **Associations**.
   - Remove the associations from:
     - `i27-vpc1`
     - `i27-vpc2`

2. **Delete Firewall Policy**:
   - After removing the associations, delete the firewall policy in the **Google Cloud Console** under **Firewall Policies**.

---
