#!/bin/bash

# -----------------------------------------------------
# Google Cloud CDN and Load Balancer Setup Script
# -----------------------------------------------------
# In this script, we will create the following resources:
# 1. **Firewall Rules**:
#    - Allows HTTP traffic on port 80.
#    - Allows health check traffic from Google's IP ranges.
# 2. **Instance Template**:
#    - A template for VM instances that includes a startup script for setting up a simple web server.
# 3. **Managed Instance Group**:
#    - A regional group of instances managed by Google Cloud, which will auto-scale and be health-checked.
# 4. **Health Check**:
#    - A TCP health check to monitor the availability of instances in the instance group.
# 5. **HTTP Load Balancer**:
#    - A global load balancer that routes traffic to the managed instance group.
# 6. **Backend Service**:
#    - A backend service that links the managed instance group with the load balancer.
# 7. **URL Map and HTTP Proxy**:
#    - A URL map and HTTP proxy to route requests to the appropriate backend service.
# 8. **Forwarding Rule**:
#    - A global forwarding rule that directs traffic to the load balancer on port 80.
# 9. **Test VM**:
#    - A simple VM in the us-central1-b zone for testing purposes.
# -----------------------------------------------------

# Enable the Compute Engine API if not already done
# This API is required to manage compute resources like VM instances and firewalls
gcloud services enable compute.googleapis.com

# Assign the current project ID to a shell variable for future use
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')

# Assign the bucket name (used for startup script) to a variable
BUCKET_NAME="noted-runway-429202-q4-terra"

# -----------------------------------------------------
# Firewall Rules Setup
# -----------------------------------------------------
# Create a firewall rule to allow HTTP traffic (port 80) from any source IP
gcloud compute firewall-rules create http-allow \
    --direction=INGRESS --priority=1000 --network=default \
    --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# Create a firewall rule to allow traffic for health checks from Google's IP ranges
gcloud compute firewall-rules create health-check-allow \
    --direction=INGRESS --priority=1000 --network=default \
    --action=ALLOW --rules=tcp --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=http-server

# -----------------------------------------------------
# Instance Template and Managed Instance Group Setup
# -----------------------------------------------------
# Create an instance template that will be used to launch VMs in the instance group
# This template points to a startup script stored in the GCS bucket defined by $BUCKET_NAME
gcloud compute instance-templates create cdn-demo-template \
    --machine-type=e2-micro \
    --metadata=startup-script-url=gs://$BUCKET_NAME/website-script/cdn-website-script.sh \
    --tags=http-server \
    --boot-disk-device-name=cdn-demo-template

# Create a health check to monitor the instance group's health via TCP on port 80
gcloud compute health-checks create tcp health-check \
    --timeout=5 --check-interval=10 --unhealthy-threshold=3 \
    --healthy-threshold=2 --port=80

# Create a managed instance group using the previously created template
# The group is set up in the australia-southeast1-a zone with proactive instance redistribution
gcloud beta compute instance-groups managed create australia-southeast1-group \
    --base-instance-name=australia-southeast1-group \
    --template=cdn-demo-template --size=1 \
    --zones=australia-southeast1-a \
    --instance-redistribution-type=PROACTIVE \
    --health-check=health-check --initial-delay=300

# Set named ports for the managed instance group to define which port (HTTP on 80) the service listens on
gcloud compute instance-groups managed set-named-ports australia-southeast1-group \
    --named-ports http:80 \
    --region australia-southeast1

# -----------------------------------------------------
# HTTP Load Balancer Setup
# -----------------------------------------------------
# Create a backend service for the load balancer and attach the health check
gcloud compute backend-services create http-backend \
    --protocol HTTP \
    --health-checks health-check \
    --global

# Add the instance group to the backend service with load balancing mode set to rate-based (50 requests per instance)
gcloud compute backend-services add-backend http-backend \
    --balancing-mode=RATE \
    --max-rate-per-instance=50 \
    --capacity-scaler=1 \
    --instance-group=australia-southeast1-group \
    --instance-group-region=australia-southeast1 \
    --global

# Create a URL map to route incoming traffic to the backend service
gcloud compute url-maps create http-lb \
    --default-service=http-backend

# Create an HTTP proxy to forward requests to the URL map
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map=http-lb

# Create a global forwarding rule to direct traffic on port 80 to the load balancer proxy
gcloud compute forwarding-rules create http-frontend \
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80

# -----------------------------------------------------
# Additional Test Instance Creation
# -----------------------------------------------------
# Create a testing VM in the us-central1-b zone to verify connectivity across regions
gcloud compute instances create testing-instance \
    --zone=us-central1-b \
    --machine-type=f1-micro

# -----------------------------------------------------
# Get the Load Balancer Frontend IP
# -----------------------------------------------------
# Retrieve the frontend IP address of the load balancer and store it in the FRONTEND variable
for FRONTEND in $(gcloud compute forwarding-rules describe http-frontend --format="get(IPAddress)" --global)
do
  gcloud compute forwarding-rules describe http-frontend --format="get(IPAddress)" --global
done

# Clear the screen and print the load balancer's IP address to the user
clear
echo "--------------------------------"
echo "Script complete! Please wait about 5 minutes for your load balancer to initialize."
echo "You can access the frontend load balancer IP at: $FRONTEND"
echo "If the website is not yet reachable, wait a few more minutes and try again."
echo "--------------------------------"
