### Overview of Resources Created in this Script:

This script configures the core infrastructure for a Google Cloud-based global load balancer. Here’s a summary of the resources created:

1. **VPC Network** (`i27-global-lb-vpc`): A custom VPC network for isolating resources.
2. **Subnets**:
   - `us-central1` (10.0.0.0/24): Subnet in the `us-central1` region.
   - `asia-southeast1` (10.1.0.0/24): Subnet in the `asia-southeast1` region.
3. **Firewall Rules**:
   - Allows SSH (22), HTTP (80), and ICMP traffic from any source.
   - Allows traffic from Google’s health check IP ranges (`130.211.0.0/22` and `35.191.0.0/16`) to ensure successful health checks.
4. **Startup Script**: Defines a startup script for instances, installing NGINX and creating a customized webpage that displays the server hostname and IP.
5. **Instance Templates**:
   - `us-central1` Instance Template: Configures instances in the `us-central1` region with startup scripts.
   - `asia-southeast1` Instance Template: Configures instances in the `asia-southeast1` region with startup scripts.
6. **Global Health Check** (`i27-global-lb-health-check`): A health check configured on port 80 to monitor instance health.
7. **Managed Instance Groups**:
   - `us-central1` MIG: Deploys instances in `us-central1` with specified zones and health checks.
   - `asia-southeast1` MIG: Deploys instances in `asia-southeast1` with specified zones and health checks.
8. **Named Ports**: Configures named ports (`http:80`) for each managed instance group to allow HTTP traffic.
9. **Static Global IP Address** (`i27-global-lb-ip`): Reserves a global IP address to use with the load balancer.

---
### **0. Export Project ID**
```bash
export PROJECT_ID=$(gcloud config get-value project)
``` 
### 1. Create the VPC Network
```bash
gcloud compute networks create i27-global-lb-vpc --subnet-mode=custom
```

### 2. Create Subnets in `us-central1` and `asia-southeast1` (Singapore)
```bash
# Subnet in us-central1
gcloud compute networks subnets create i27-global-lb-us-central1-subnet \
    --network=i27-global-lb-vpc \
    --region=us-central1 \
    --range=10.0.0.0/24

# Subnet in asia-southeast1 (Singapore)
gcloud compute networks subnets create i27-global-lb-asia-southeast1-subnet \
    --network=i27-global-lb-vpc \
    --region=asia-southeast1 \
    --range=10.1.0.0/24
```

### 3. Create Firewall Rules

#### Allow SSH (Port 22), HTTP (Port 80), and ICMP from Any Source
```bash
gcloud compute firewall-rules create i27-allow-ssh-http-icmp \
    --network=i27-global-lb-vpc \
    --allow tcp:22,tcp:80,icmp \
    --source-ranges=0.0.0.0/0
```

#### Important Note for Students:
> **Remember**: Google Cloud health checks use specific IP ranges (`130.211.0.0/22` and `35.191.0.0/16`). Always include these IP ranges in your firewall rules to avoid failed health checks. If these ranges are not allowed, instances will be marked as unhealthy, and the load balancer won’t be able to route traffic effectively.

#### Allow Health Check Traffic from Google’s Health Check IP Ranges
```bash
gcloud compute firewall-rules create i27-allow-health-checks \
    --network=i27-global-lb-vpc \
    --allow tcp \
    --source-ranges=130.211.0.0/22,35.191.0.0/16
```

### 4. Define and Save the Startup Script
```bash
STARTUP_SCRIPT_CONTENT=$(cat <<EOF
#!/bin/bash
sudo apt update
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
HOSTNAME=\$(hostname)
sudo echo "<!DOCTYPE html> <html> <head><style> body { font-family: Arial, sans-serif; color: #333333; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f2f2f2; } h1 { color: #005580; } p { font-size: 1.2em; color: #555555; } </style></head> <body> <div> <h1>i27academy Google Cloud Platform</h1> <p><strong style='color: #ff7500;'>Server Hostname:</strong> \${HOSTNAME}</p> <p><strong>Server IP Address:</strong> \$(hostname -I)</p> </div> </body></html>" | sudo tee /var/www/html/index.html
EOF
)

echo "Creating startup script file..."
echo "$STARTUP_SCRIPT_CONTENT" > startup-script.sh
chmod +x startup-script.sh
```

### 5. Create Instance Templates for `us-central1` and `asia-southeast1`

#### Instance Template for `us-central1`
```bash
gcloud compute instance-templates create i27-global-lb-central-instance-template \
    --region=us-central1 \
    --instance-template-region=us-central1 \
    --machine-type=e2-medium \
    --network=i27-global-lb-vpc \
    --subnet=i27-global-lb-us-central1-subnet \
    --metadata-from-file startup-script=startup-script.sh
```

#### Instance Template for `asia-southeast1` (Singapore)
```bash
gcloud compute instance-templates create i27-global-lb-singapore-instance-template \
    --region=asia-southeast1 \
    --instance-template-region=asia-southeast1 \
    --machine-type=e2-medium \
    --network=i27-global-lb-vpc \
    --subnet=i27-global-lb-asia-southeast1-subnet \
    --metadata-from-file startup-script=startup-script.sh
```

### 6. Create a Global Health Check
```bash
gcloud compute health-checks create http i27-global-lb-health-check \
    --global \
    --port 80 \
    --request-path="/"
```

### 7. Create Managed Instance Groups in Specific Zones Using the Fully Qualified Path for Regional Instance Templates

#### Managed Instance Group in `us-central1`
```bash
gcloud compute instance-groups managed create i27-global-lb-central-mig \
    --base-instance-name=i27-global-lb-central \
    --template=projects/$PROJECT_ID/regions/us-central1/instanceTemplates/i27-global-lb-central-instance-template \
    --size=2 \
    --zones=us-central1-c,us-central1-f \
    --health-check=i27-global-lb-health-check \
    --initial-delay=300
```

#### Managed Instance Group in `asia-southeast1` (Singapore)
```bash
gcloud compute instance-groups managed create i27-global-lb-singapore-mig \
    --base-instance-name=i27-global-lb-singapore \
    --template=projects/$PROJECT_ID/regions/asia-southeast1/instanceTemplates/i27-global-lb-singapore-instance-template \
    --size=2 \
    --zones=asia-southeast1-a,asia-southeast1-b \
    --health-check=i27-global-lb-health-check \
    --initial-delay=300
```

### 8. Set Named Ports for Each Managed Instance Group

#### Named Port for `us-central1` Managed Instance Group
```bash
gcloud compute instance-groups managed set-named-ports i27-global-lb-central-mig \
    --named-ports=http:80 \
    --region=us-central1
```

#### Named Port for `asia-southeast1` (Singapore) Managed Instance Group
```bash
gcloud compute instance-groups managed set-named-ports i27-global-lb-singapore-mig \
    --named-ports=http:80 \
    --region=asia-southeast1
```

### 9. Create Static Global Ip address
```bash
# Create a static external IP address
gcloud compute addresses create i27-global-lb-ip --global

```

---

> **Next Steps**: With the core infrastructure now configured, proceed with setting up the load balancer, backend service, URL map, and forwarding rules directly in the Google Cloud Console. This approach allows for a hands-on experience with load balancer configurations and helps ensure each component is correctly associated. 

