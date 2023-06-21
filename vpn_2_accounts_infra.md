# 1st account
```bash
echo Creating Network-1
gcloud services enable compute.googleapis.com
gcloud compute networks create network-1 --subnet-mode=custom

gcloud compute networks subnets create subnet-1a --network=network-1 --region=us-west1 --range=10.0.1.0/24

gcloud compute networks subnets create subnet-1b --network=network-1 --region=us-central1 --range=10.0.2.0/24

gcloud compute firewall-rules create allow-ssh-icmp-network-1 --direction=INGRESS --priority=1000 --network=network-1 --action=ALLOW --rules=tcp:22,icmp --source-ranges=0.0.0.0/0

gcloud compute instances create instance-1 --zone=us-west1-b --machine-type=f1-micro --subnet=subnet-1a --no-address

gcloud compute instances create instance-2 --zone=us-central1-b --machine-type=f1-micro --subnet=subnet-1b --no-address

gcloud compute addresses create network-1-static-ip --region=us-central1 --network-tier=PREMIUM

```



# 2nd account
```bash
gcloud services enable compute.googleapis.com
gcloud compute networks create network-2 --subnet-mode=custom

gcloud compute networks subnets create subnet-2a --network=network-2 --region=us-east1 --range=10.1.3.0/24

gcloud compute networks subnets create subnet-2b --network=network-2 --region=us-central1 --range=10.1.4.0/24

gcloud compute firewall-rules create allow-ssh-icmp-network-2 --direction=INGRESS --priority=1000 --network=network-2 --action=ALLOW --rules=tcp:22,icmp --source-ranges=0.0.0.0/0

gcloud compute instances create instance-3 --zone=us-east1-b --machine-type=f1-micro --subnet=subnet-2a --no-address

gcloud compute instances create instance-4 --zone=us-central1-b --machine-type=f1-micro --subnet=subnet-2b --no-address

gcloud compute addresses create network-2-static-ip --region=us-central1 --network-tier=PREMIUM
```

## Extra subnet
gcloud compute networks subnets create subnet-1c --network=network-1 --region=us-central1 --range=10.0.3.0/24

## Extra instance
gcloud compute instances create instance-extra --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-1c


## Extra subnet
gcloud compute networks subnets create subnet-1d --network=network-1 --region=us-central1 --range=10.0.4.0/24

## Extra instance
gcloud compute instances create instance-extra-bgp --zone=us-central1-a --machine-type=f1-micro --subnet=subnet-1d


## new more instance
gcloud compute instances create instance-extra-bgp-extra --zone=us-west1-b --machine-type=f1-micro --subnet=subnet-1d
