
# Google Cloud VPC, Subnet, and VM Creation Guide

This guide provides `gcloud` commands to create a Virtual Private Cloud (VPC) network in both auto and custom modes, along with instructions to create subnets and virtual machines.

## 1. Create VPC in Auto Mode

Auto mode automatically creates subnets in each region.

```bash
gcloud compute networks create my-auto-vpc \
    --subnet-mode=auto
```

## 2. Create VPC in Custom Mode

Custom mode requires you to create each subnet manually.

```bash
gcloud compute networks create my-custom-vpc \
    --subnet-mode=custom
```

## 3. Create a Subnet in Custom Mode VPC

Specify the region and IP range for each subnet.

```bash
gcloud compute networks subnets create my-custom-subnet \
    --network=my-custom-vpc \
    --region=us-central1 \
    --range=10.0.0.0/24
```

## 4. Create Virtual Machines (VMs) in a Specific VPC and Subnet

Specify the VPC network and subnet when creating the VM instance. You can also set a specific zone for the VM.

```bash
gcloud compute instances create my-vm-auto \
    --zone=us-central1-a \
    --network=my-auto-vpc

gcloud compute instances create my-vm-custom \
    --zone=us-central1-a \
    --network=my-custom-vpc \
    --subnet=my-custom-subnet
```


