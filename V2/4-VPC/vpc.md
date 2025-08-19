#  Google Cloud VPC (Virtual Private Cloud)

## 1.  When a Project is Created in GCP 

* Every GCP project automatically comes with a  default VPC .
* This default VPC is created in  auto mode  with:

  * One subnet  per region .
  * Predefined IP ranges.
  * Basic firewall rules (allow SSH, RDP, ICMP).

👉 But in  real-world companies , we  don’t use the default VPC  because:

* The IP ranges may  clash  with corporate networks.
* Too many unused subnets get created.
* Not secure enough for enterprise use.

---

## 2.  Why Do We Need a VPC? 

* A  VPC provides networking for all resources  (VMs, Databases, Kubernetes clusters, etc.) inside the project.
* Without a VPC, resources cannot  communicate  with each other or with the internet.

 Real-World Needs for a VPC: 

1.  Isolation  – Separate your project’s workloads from others.
2.  Control  – Decide who talks to whom (via firewall & routes).
3.  Private Communication  – Use private IPs for VM-to-VM traffic (faster, secure, cheaper).
4.  Hybrid Connectivity  – Connect GCP workloads to your  on-premises datacenter .
5.  Scalability  – Create multiple subnets across regions.

👉 In short:  A VPC is the foundation of cloud networking. 
Every resource you deploy must live inside a VPC.

---

## 3.  What is a VPC (Definition) 

* A  Virtual Private Cloud (VPC)  is a  global virtual network  in Google Cloud.
* It lets you define:

  *  Subnets  → regional IP ranges for workloads.
  *  Firewall Rules  → what traffic is allowed/denied.
  *  Routes  → how packets travel inside/outside the network.
  *  Peering / VPN / Interconnect  → connect to other networks.

👉 Think of a VPC like your  company’s private office LAN , but hosted in GCP and stretched across the globe.

---

## 4.  Subnets in VPC 

*  Subnetwork = A regional portion of the VPC’s IP range. 
* Example:

  * VPC CIDR = `10.0.0.0/16` (65,536 IPs).
  * Subnet in `us-central1`: `10.0.0.0/24`.
  * Subnet in `us-east1`: `10.0.1.0/24`.
* Subnets allow you to place workloads in  specific regions .
* VMs in different regions can still communicate  over Google’s private backbone .

---

## 5.  Auto Mode vs Custom Mode 

###  Auto Mode 

* Created by default with a project.
* 1 subnet  per region  (pre-allocated IPs).
* Good for  testing & learning .
*  Limitations:  Wastes IP space, less flexibility.

###  Custom Mode 

* You manually create subnets.
* You  choose IP ranges and regions .
* Standard in  production environments .
* Enables  hybrid connectivity  with on-premises networks (non-overlapping CIDRs).

👉  Best Practice : Always convert/replace auto mode →  custom mode  for real projects.

---

## 6.  CIDR Ranges 

* CIDR =  Classless Inter-Domain Routing .
* Defines IP ranges in the format: `network_address/prefix_length`.
* Example:

  * `10.0.0.0/24` → 256 IPs (254 usable).
  * `10.0.0.0/20` → 4096 IPs.

 Private IP ranges (RFC 1918): 

* `10.0.0.0/8` (Large, flexible)
* `172.16.0.0/12`
* `192.168.0.0/16`

👉 Always plan CIDR ranges  carefully  to avoid conflicts with on-premises networks.

---

## 7.  Key Real-World Example 

Imagine a company  i27Cart  moving apps to GCP:

* They create a project `i27cart-prod`.
* They don’t use the  default VPC .
* They design a  Custom Mode VPC :

  * VPC: `prod-vpc`
  * Subnet in `us-central1`: `10.10.1.0/24` (for app servers)
  * Subnet in `us-east1`: `10.10.2.0/24` (for database servers)
  * Subnet in `asia-south1`: `10.10.3.0/24` (for India users)
* Firewall rules: allow only  app → DB communication .
* Peering: connect with  on-premises Hyderabad datacenter .

👉 This design ensures:  security, scalability, and no IP conflicts .

---
