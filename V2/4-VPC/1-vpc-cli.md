
#  gcloud Commands for VPC & Subnets 
## 1.  List VPCs 

```bash
gcloud compute networks list
```

* Shows all VPCs in your project.

---

## 2.  Create a Custom Mode VPC 

```bash
gcloud compute networks create my-custom-vpc \
    --subnet-mode=custom
```

* Creates a VPC named `my-custom-vpc`.
*  No subnets  are created by default → you must create them manually.

---

## 3.  Create a Subnet 

```bash
gcloud compute networks subnets create my-subnet-central \
    --network=my-custom-vpc \
    --region=us-central1 \
    --range=10.0.1.0/24
```

* Creates a subnet `my-subnet-central` inside `my-custom-vpc`.
* Region = `us-central1`.
* CIDR range = `10.0.1.0/24`.

---

## 4.  List Subnets 

```bash
gcloud compute networks subnets list
```

* Lists all subnets in all VPCs.
* Shows  NAME, REGION, NETWORK, RANGE, GATEWAY\_ADDRESS .

👉 To filter by VPC:

```bash
gcloud compute networks subnets list --network=my-custom-vpc
```

---

## 5.  Delete a Subnet 

```bash
gcloud compute networks subnets delete my-subnet-central \
    --region=us-central1
```

* Deletes the subnet from the given region.

---

## 6.  Delete a VPC 

```bash
gcloud compute networks delete my-custom-vpc
```

* Deletes the entire VPC.
* ⚠️ You must first  delete all subnets  in the VPC.

---

## 7.  Create an Auto Mode VPC 

```bash
gcloud compute networks create my-auto-vpc \
    --subnet-mode=auto
```

* Google automatically creates  1 subnet in every region .
* Each subnet gets predefined ranges (e.g., `10.128.0.0/20`).

---

## 8.  Convert Auto Mode → Custom Mode (optional) 

```bash
gcloud compute networks update my-auto-vpc \
    --switch-to-custom-subnet-mode
```

* Converts auto VPC into  custom mode .
* No new subnets are created automatically after conversion.

---

## 9.  Useful Describe Commands 

### Check details of a VPC

```bash
gcloud compute networks describe my-custom-vpc
```

### Check details of a Subnet

```bash
gcloud compute networks subnets describe my-subnet-central \
    --region=us-central1
```

---

## 10.  Firewall Example (Optional, we shall look in detail later) 

Create a firewall rule to allow SSH (port 22):

```bash
gcloud compute firewall-rules create allow-ssh \
    --network=my-custom-vpc \
    --allow=tcp:22
```

