#!/bin/bash

# This script creates the following resources for a global HTTP load balancer setup:

# 1. VPC Network and Subnets:
#    - Custom VPC named `i27-global-lb-vpc`
#    - Subnet in `us-central1` region
#    - Subnet in `asia-southeast1` region
#
# 2. Firewall Rules:
#    - Rule allowing SSH (22), HTTP (80), and ICMP traffic from any source
#    - Rule allowing health check traffic from Google’s health check IP ranges
#
# 3. Startup Script:
#    - Script to configure instances with NGINX and a customized HTML page displaying server details
#
# 4. Instance Templates:
#    - Template for `us-central1` region
#    - Template for `asia-southeast1` region
#
# 5. Global Health Check:
#    - Health check configured on port 80
#
# 6. Managed Instance Groups:
#    - Managed instance group in `us-central1` with health check and custom named ports
#    - Managed instance group in `asia-southeast1` with health check and custom named ports
#
# 7. Named Ports:
#    - Sets named port `http:80` on each managed instance group
#
# 8. Static Global IP Address:
#    - Reserves a global IP address for use with the load balancer
#
# 9. Backend Service:
#    - Configures backend service with load balancing, health check, and instance groups
#
# 10. Load Balancer Configuration:
#    - URL map to route traffic to the backend service
#    - Target HTTP proxy for handling HTTP traffic
#    - Forwarding rule to route traffic to the load balancer using the reserved IP address

# Begin resource creation

# Create the VPC Network
gcloud compute networks create i27-global-lb-vpc --subnet-mode=custom
echo "VPC Network created."

# Create Subnets in us-central1 and asia-southeast1 (Singapore)
gcloud compute networks subnets create i27-global-lb-us-central1-subnet \
    --network=i27-global-lb-vpc \
    --region=us-central1 \
    --range=10.0.0.0/24
echo "Subnet in us-central1 created."

gcloud compute networks subnets create i27-global-lb-asia-southeast1-subnet \
    --network=i27-global-lb-vpc \
    --region=asia-southeast1 \
    --range=10.1.0.0/24
echo "Subnet in asia-southeast1 created."

# Create Firewall Rules
# Allow SSH (Port 22), HTTP (Port 80), and ICMP from Any Source
gcloud compute firewall-rules create i27-allow-ssh-http-icmp \
    --network=i27-global-lb-vpc \
    --allow tcp:22,tcp:80,icmp \
    --source-ranges=0.0.0.0/0
echo "Firewall rules created."

# Allow Health Check Traffic from Google’s Health Check IP Ranges
gcloud compute firewall-rules create i27-allow-health-checks \
    --network=i27-global-lb-vpc \
    --allow tcp \
    --source-ranges=130.211.0.0/22,35.191.0.0/16
echo "Health check firewall rule created."

# Define and Save the Startup Script
STARTUP_SCRIPT_CONTENT=$(cat <<EOF
#!/bin/bash
sudo apt update
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
HOSTNAME=\$(hostname)
sudo echo "<!DOCTYPE html> <html> <head><style> body { font-family: Arial, sans-serif; color: #333333; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f2f2f2; } h1 { color: #005580; } p { font-size: 1.2em; color: #555555; } .hostname { color: #ff7500; } </style></head> <body> <div> <h1>i27academy Google Cloud Platform</h1> <p><strong>Server Hostname:</strong> <span class='hostname'>\${HOSTNAME}</span></p> <p><strong>Server IP Address:</strong> \$(hostname -I)</p> </div> </body></html>" | sudo tee /var/www/html/index.html
EOF
)

echo "$STARTUP_SCRIPT_CONTENT" > startup-script.sh
chmod +x startup-script.sh
echo "Startup script created."

# Create Instance Templates for us-central1 and asia-southeast1

gcloud compute instance-templates create i27-global-lb-central-instance-template \
    --region=us-central1 \
    --instance-template-region=us-central1 \
    --machine-type=e2-medium \
    --network=i27-global-lb-vpc \
    --subnet=i27-global-lb-us-central1-subnet \
    --metadata-from-file startup-script=startup-script.sh
echo "Instance template for us-central1 created."

gcloud compute instance-templates create i27-global-lb-singapore-instance-template \
    --region=asia-southeast1 \
    --instance-template-region=asia-southeast1 \
    --machine-type=e2-medium \
    --network=i27-global-lb-vpc \
    --subnet=i27-global-lb-asia-southeast1-subnet \
    --metadata-from-file startup-script=startup-script.sh
echo "Instance template for asia-southeast1 created."

# Create a Global Health Check
gcloud compute health-checks create http i27-global-lb-health-check \
    --global \
    --port 80 \
    --request-path="/"
echo "Global health check created."

# Create Managed Instance Groups in Specific Zones Using the Fully Qualified Path for Regional Instance Templates

gcloud compute instance-groups managed create i27-global-lb-central-mig \
    --base-instance-name=i27-global-lb-central \
    --template=projects/infra-radius-438300-r7/regions/us-central1/instanceTemplates/i27-global-lb-central-instance-template \
    --size=2 \
    --zones=us-central1-c,us-central1-f \
    --health-check=i27-global-lb-health-check \
    --initial-delay=300
echo "Managed instance group in us-central1 created."

gcloud compute instance-groups managed create i27-global-lb-singapore-mig \
    --base-instance-name=i27-global-lb-singapore \
    --template=projects/infra-radius-438300-r7/regions/asia-southeast1/instanceTemplates/i27-global-lb-singapore-instance-template \
    --size=2 \
    --zones=asia-southeast1-a,asia-southeast1-b \
    --health-check=i27-global-lb-health-check \
    --initial-delay=300
echo "Managed instance group in asia-southeast1 created."

# Set Named Ports for Each Managed Instance Group

gcloud compute instance-groups managed set-named-ports i27-global-lb-central-mig \
    --named-ports=http:80 \
    --region=us-central1
echo "Named ports set for us-central1 managed instance group."

gcloud compute instance-groups managed set-named-ports i27-global-lb-singapore-mig \
    --named-ports=http:80 \
    --region=asia-southeast1
echo "Named ports set for asia-southeast1 managed instance group."

# Create a static external IP address
gcloud compute addresses create i27-global-lb-ip --global
echo "Static external IP address created."


# Create a backend service with the health check
gcloud compute backend-services create i27-global-lb-backend-service \
    --global \
    --protocol=HTTP \
    --health-checks=i27-global-lb-health-check \
    --port-name=http \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --locality-lb-policy=ROUND_ROBIN \
    --connection-draining-timeout=300 \
    --session-affinity=NONE \
    --timeout=30

# Add the us-central1 instance group to the backend service
gcloud compute backend-services add-backend i27-global-lb-backend-service \
    --global \
    --instance-group=i27-global-lb-central-mig \
    --instance-group-region=us-central1

# Add the asia-southeast1 instance group to the backend service
gcloud compute backend-services add-backend i27-global-lb-backend-service \
    --global \
    --instance-group=i27-global-lb-singapore-mig \
    --instance-group-region=asia-southeast1


# Create a URL Map: Load Balancer Configuration
gcloud compute url-maps create i27-global-lb-url-map-alb \
    --default-service=i27-global-lb-backend-service

# Create a Target HTTP Proxy
gcloud compute target-http-proxies create i27-global-lb-http-proxy \
    --url-map=i27-global-lb-url-map-alb


#  Create a Forwarding Rule
gcloud compute forwarding-rules create i27-global-lb-forwarding-rule \
    --global \
    --target-http-proxy=i27-global-lb-http-proxy \
    --address=i27-global-lb-ip \
    --ports=80


# Get the static IP address
STATIC_IP=$(gcloud compute addresses describe i27-global-lb-ip --global --format="get(address)")

echo "-------------------------------"
echo "Script complete. Wait about 5 minutes for your load balancer to initialize, then access the frontend address in a new tab."
echo -e "\nYour load balancer frontend IP address is: \033[1;32m$STATIC_IP\033[0m"
echo "If you receive an error for the website, wait a few more minutes and try again."
echo "-------------------------------"
