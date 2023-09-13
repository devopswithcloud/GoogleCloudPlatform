# Replicating CLoud env
## Cloud VPC setup
```
gcloud compute networks create vpc-demo --subnet-mode custom
```

### Create subnets
```bash
# Now create subnet vpc-demo-us-subnet1 in us-central1 region:
gcloud beta compute networks subnets create vpc-demo-subnet1 \
--network vpc-demo --range 10.1.1.0/24 --region us-central1

#Create subnet vpc-demo-subnet2 in us-east1 region:
gcloud beta compute networks subnets create vpc-demo-subnet2 \
--network vpc-demo --range 10.2.1.0/24 --region us-east1
```

### Create firewall rules
```bash
# Create a firewall rule to allow all internal traffic within the network:
gcloud compute firewall-rules create vpc-demo-allow-internal \
  --network vpc-demo \
  --allow tcp:0-65535,udp:0-65535,icmp \
  --source-ranges 10.0.0.0/8

# Create a firewall rule to allow ssh, icmp from anywhere:
gcloud compute firewall-rules create vpc-demo-allow-ssh-icmp \
    --network vpc-demo \
    --allow tcp:22,icmp \
    --source-ranges 0.0.0.0/0
```

### Create vm instances in network `vpc-demo`
```bash
# Create a vm instance vpc-demo-instance1 in zone us-central1-b:
gcloud compute instances create vpc-demo-instance1 --zone us-central1-b --subnet vpc-demo-subnet1 --machine-type f1-micro --no-address
# Create a vm instance vpc-demo-instance2 in zone us-east1-b:
gcloud compute instances create vpc-demo-instance2 --zone us-east1-b --subnet vpc-demo-subnet2 --machine-type f1-micro --no-address

```

# Replicating on-premises setup
## Create on-prem network
```bash
# Create a vpc network called on-prem:
gcloud compute networks create on-prem --subnet-mode custom
```

### Create subnets
```bash
# Create subnet on-prem-subnet1:
gcloud beta compute networks subnets create on-prem-subnet1 \
--network on-prem --range 192.168.1.0/24 --region us-central1
```
### Create firewall rules
```bash
# Create a firewall rule to allow all internal traffic within the network:
gcloud compute firewall-rules create on-prem-allow-internal \
  --network on-prem \
  --allow tcp:0-65535,udp:0-65535,icmp \
  --source-ranges 192.168.0.0/16
```

### 
```bash
# Create a firewall rule to allow ssh, rdp, http, icmp to the instances:
gcloud compute firewall-rules create on-prem-allow-ssh-icmp \
    --network on-prem \
    --allow tcp:22,icmp
    --source-ranges 0.0.0.0
```

### Create a test instance in network on-prem
```bash
#Create an instance vpc-demo-instance1 in region us-central1
gcloud compute instances create on-prem-instance1 --zone us-central1-a --subnet on-prem-subnet1 --machine-type f1-micro --no-address
```

# HA-VPN setup
```bash
# Create a Cloud HA-VPN in network vpc-demo:
gcloud beta compute vpn-gateways create vpc-demo-vpn-gw1 --network vpc-demo --region us-central1

# Create a Cloud HA-VPN in network on-prem:
gcloud beta compute vpn-gateways create on-prem-vpn-gw1 --network on-prem --region us-central1
```

### View details of the vpn-gateways
```bash
# View details of vpn-gateway vpc-demo-vpn-gw1:
gcloud beta compute vpn-gateways describe vpc-demo-vpn-gw1 --region us-central1

# View details of vpn-gateway on-prem-vpn-gw1:
gcloud beta compute vpn-gateways describe on-prem-vpn-gw1 --region us-central1
```

### Create cloud routers
```bash
# Create a cloud router in network vpc-demo:
gcloud compute routers create vpc-demo-router1 \
    --region us-central1 \
    --network vpc-demo \
    --asn 65001

# Create a cloud router in network on-prem:
gcloud compute routers create on-prem-router1 \
    --region us-central1 \
    --network on-prem \
    --asn 65002
```

# Create two VPN tunnels in GCP VPC
```bash
# Create the first VPN tunnels in network vpc-demo:
gcloud beta compute vpn-tunnels create vpc-demo-tunnel0 \
    --peer-gcp-gateway on-prem-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router vpc-demo-router1 \
    --vpn-gateway vpc-demo-vpn-gw1 \
    --interface 0
# Now create the second tunnel:
gcloud beta compute vpn-tunnels create vpc-demo-tunnel1 \
    --peer-gcp-gateway on-prem-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router vpc-demo-router1 \
    --vpn-gateway vpc-demo-vpn-gw1 \
    --interface 1
```

## Create two vpn tunnels in network on-prem
```bash
# Create on-prem-tunnel0 with the following command:
gcloud beta compute vpn-tunnels create on-prem-tunnel0 \
    --peer-gcp-gateway vpc-demo-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router on-prem-router1 \
    --vpn-gateway on-prem-vpn-gw1 \
    --interface 0
# Create on-prem-tunnel1 with the following command:
gcloud beta compute vpn-tunnels create on-prem-tunnel1 \
    --peer-gcp-gateway vpc-demo-vpn-gw1 \
    --region us-central1 \
    --ike-version 2 \
    --shared-secret [SHARED_SECRET] \
    --router on-prem-router1 \
    --vpn-gateway on-prem-vpn-gw1 \
    --interface 1
```

## Create bgp peering for each tunnel
```bash
# Create the router interface for tunnel0 in network vpc-demo:
gcloud compute routers add-interface vpc-demo-router1 \
    --interface-name if-tunnel0-to-on-prem \
    --ip-address 169.254.0.1 \
    --mask-length 30 \
    --vpn-tunnel vpc-demo-tunnel0 \
    --region us-central1

# And the bgp peer for tunnel0 in network vpc-demo:
gcloud compute routers add-bgp-peer vpc-demo-router1 \
    --peer-name bgp-on-prem-tunnel0 \
    --interface if-tunnel0-to-on-prem \
    --peer-ip-address 169.254.0.2 \
    --peer-asn 65002 \
    --region us-central1

# Create router interface for tunnel1 in network vpc-demo:
gcloud compute routers add-interface vpc-demo-router1 \
    --interface-name if-tunnel1-to-on-prem \
    --ip-address 169.254.1.1 \
    --mask-length 30 \
    --vpn-tunnel vpc-demo-tunnel1 \
    --region us-central1
# And the bgp peer for tunnel1 in network vpc-demo:
gcloud compute routers add-bgp-peer vpc-demo-router1 \
    --peer-name bgp-on-prem-tunnel1 \
    --interface if-tunnel1-to-on-prem \
    --peer-ip-address 169.254.1.2 \
    --peer-asn 65002 \
    --region us-central1
# Create router interface for tunnel0 in network on-prem:
gcloud compute routers add-interface on-prem-router1 \
    --interface-name if-tunnel0-to-vpc-demo \
    --ip-address 169.254.0.2 \
    --mask-length 30 \
    --vpn-tunnel on-prem-tunnel0 \
    --region us-central1
# And the bgp peer for tunnel0 in network on-prem:
gcloud compute routers add-bgp-peer on-prem-router1 \
    --peer-name bgp-vpc-demo-tunnel0 \
    --interface if-tunnel0-to-vpc-demo \
    --peer-ip-address 169.254.0.1 \
    --peer-asn 65001 \
    --region us-central1
# Create router interface for tunnel1 in network on-prem:
gcloud compute routers add-interface  on-prem-router1 \
    --interface-name if-tunnel1-to-vpc-demo \
    --ip-address 169.254.1.2 \
    --mask-length 30 \
    --vpn-tunnel on-prem-tunnel1 \
    --region us-central1
# And the bgp peer for tunnel1 in network on-prem:
gcloud compute routers add-bgp-peer  on-prem-router1 \
    --peer-name bgp-vpc-demo-tunnel1 \
    --interface if-tunnel1-to-vpc-demo \
    --peer-ip-address 169.254.1.1 \
    --peer-asn 65001 \
    --region us-central1

# Verify router configurations
gcloud compute routers describe vpc-demo-router1 \
    --region us-central1
```

### Configure Firewall rules to allow traffic from the remote VPC
```bash
# Allow traffic from network vpc on-prem to vpc-demo:
gcloud compute firewall-rules create vpc-demo-allow-subnets-from-on-prem \
    --network vpc-demo \
    --allow tcp,udp,icmp \
    --source-ranges 192.168.1.0/24

# Allow traffic from vpc-demo to network vpc on-prem:
gcloud compute firewall-rules create on-prem-allow-subnets-from-vpc-demo \
    --network on-prem \
    --allow tcp,udp,icmp \
    --source-ranges 10.1.1.0/24,10.2.1.0/24
```

### Verify the status of the tunnels
```bash
# List the VPN tunnels you just created. There should be four vpn tunnels - two tunnels for each VPN gateway:
gcloud beta compute vpn-tunnels list

# Now, verify that each tunnel is up. First, vpc-demo-tunnel0:
gcloud beta compute vpn-tunnels describe vpc-demo-tunnel0 \
      --region us-central1

# Now, verify that each tunnel is up. First, vpc-demo-tunnel0
gcloud beta compute vpn-tunnels describe vpc-demo-tunnel0 \
      --region us-central1
# Next, vpc-demo-tunnel
gcloud beta compute vpn-tunnels describe vpc-demo-tunnel1 \
      --region us-central1
# Next, on-prem-tunnel0:
gcloud beta compute vpn-tunnels describe on-prem-tunnel0 \
      --region us-central1
# Next, on-prem-tunnel1:
gcloud beta compute vpn-tunnels describe on-prem-tunnel1 \
      --region us-central1
```

### Verify private connectivity over VPN
```bash
gcloud compute ssh on-prem-instance1 --zone us-central1-a
ping 10.2.1.2 # Ping wont work
```

### Global routing with VPN
```bash
# update the bgp-routing mode from vpc-demo to GLOBAL:
gcloud compute networks update vpc-demo --bgp-routing-mode GLOBAL
# Verify the change:
gcloud compute networks describe vpc-demo

ping 10.2.1.2 # ping should be sucess
```

### Verify high availability of tunnels
```bash
# Bring tunnel0 in network vpc-demo down:
gcloud compute vpn-tunnels delete vpc-demo-tunnel0  --region us-central1 # Respond Y when asked to verify the deletion.

# Verify that the tunnel is down by running:
gcloud compute vpn-tunnels describe on-prem-tunnel0  --region us-central1 # The status should show as FIRST_HANDSHAKE.

ping 10.1.1.2 # Pings are still successful as the traffic is now sent over the second tunnel.
```

# Testing Dynamic Routing
```bash
# Create subnet dynamic-subnet in us-east1 region
gcloud beta compute networks subnets create dynamic-subnet \
--network vpc-demo --range 10.3.1.0/24 --region us-east1

# Create a dynamic instance vpc-demo-instance2 in zone us-east1-b:
gcloud compute instances create dynamic-instance --zone us-east1-b --subnet dynamic-subnet --machine-type f1-micro --no-address
```

# Delete all resources Created
```bash
# Delete VPN tunnels
gcloud compute vpn-tunnels delete on-prem-tunnel0  --region us-central1 --quiet
gcloud compute vpn-tunnels delete vpc-demo-tunnel1  --region us-central1 --quiet
gcloud compute vpn-tunnels delete on-prem-tunnel1  --region us-central1 --quiet
gcloud compute vpn-tunnels delete vpc-demo-tunnel0 --region us-central1 --quiet

# Remove BGP peering
gcloud compute routers remove-bgp-peer vpc-demo-router1 --peer-name bgp-on-prem-tunnel0 --region us-central1
gcloud compute routers remove-bgp-peer vpc-demo-router1 --peer-name bgp-on-prem-tunnel1 --region us-central1
# gcloud compute routers remove-bgp-peer on-prem-router1 --peer-name bgp-vpc-demo-tunnel0 --region us-central1
gcloud compute routers remove-bgp-peer on-prem-router1 --peer-name bgp-vpc-demo-tunnel1 --region us-central1

# Delete cloud routers
gcloud compute  routers delete on-prem-router1 --region us-central1 --quiet
gcloud compute  routers delete vpc-demo-router1 --region us-central1 --quiet

# Delete VPN gateways
gcloud beta compute vpn-gateways delete vpc-demo-vpn-gw1 --region us-central1 --quiet
gcloud beta compute vpn-gateways delete on-prem-vpn-gw1 --region us-central1 --quiet

# Delete instances
gcloud compute instances delete vpc-demo-instance1 --zone us-central1-b --quiet
gcloud compute instances delete vpc-demo-instance2 --zone us-east1-b --quiet
gcloud compute instances delete on-prem-instance1 --zone us-central1-a --quiet
gcloud compute instances delete dynamic-instance --zone us-east1-b --quiet

# Delete firewall rules
gcloud beta compute firewall-rules delete vpc-demo-allow-internal --quiet
gcloud beta compute firewall-rules delete on-prem-allow-subnets-from-vpc-demo --quiet
gcloud beta compute firewall-rules delete on-prem-allow-ssh-icmp --quiet
gcloud beta compute firewall-rules delete on-prem-allow-internal --quiet
gcloud beta compute firewall-rules delete vpc-demo-allow-subnets-from-on-prem --quiet
gcloud beta compute firewall-rules delete vpc-demo-allow-ssh-icmp --quiet

# Delete subnets
gcloud beta compute networks subnets delete vpc-demo-subnet1 --region us-central1 --quiet
gcloud beta compute networks subnets delete vpc-demo-subnet2 --region us-east1 --quiet
gcloud beta compute networks subnets delete on-prem-subnet1 --region us-central1 --quiet
gcloud beta compute networks subnets delete dynamic-subnet --region us-east1 --quiet

# Delete VPC
gcloud compute networks delete vpc-demo  --quiet
gcloud compute networks delete on-prem --quiet
```


