#!/bin/bash

# This script sets up the following Google Cloud resources:
# 1. Two VM instances (instance-1 and instance-2) in the us-central1-a zone. UnMig should be in the same region and can be in different zone.
# 2. An unmanaged instance group named unmanaged-group-1, containing the two VM instances.
# 3. A health check named health-check with regional scope, used to monitor the instance group.
# 4. A firewall rule named allow-health-check, allowing health checks on port 80.
# 5. A global static IP address named lb-static-ip, reserved for use with a load balancer.
# 6. A startup script (startup-script.sh) is created to configure the VM instances with Nginx and a custom HTML page.

# Variables
ZONE="us-central1-a"
REGION="us-central1"
INSTANCE1="instance-1"
INSTANCE2="instance-2"
INSTANCE_GROUP="unmanaged-group-1"
HEALTH_CHECK_NAME="health-check"
FIREWALL_RULE_NAME="allow-health-check"
STATIC_IP_NAME="lb-static-ip"

# Define updated startup script content
STARTUP_SCRIPT_CONTENT=$(cat <<EOF
#!/bin/bash
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
HOSTNAME=\$(hostname)
sudo echo "<!DOCTYPE html> <html> <body style='background-color:rgb(0, 128, 128);'> <h1>i27academy Google Cloud Platform </h1> <p><strong>Server Hostname:</strong> \${HOSTNAME}</p> <p><strong>Server IP Address:</strong> \$(hostname -I) </body></html>" | sudo tee /var/www/html/index.html
EOF
)

# Create startup script file
echo "Creating startup script file..."
echo "$STARTUP_SCRIPT_CONTENT" > startup-script.sh
chmod +x startup-script.sh

# Create VM instances with tags
echo "Creating VM instances..."
gcloud compute instances create $INSTANCE1 \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --network-interface=subnet=default \
  --metadata-from-file=startup-script=startup-script.sh \
  --tags=http-server

gcloud compute instances create $INSTANCE2 \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --network-interface=subnet=default \
  --metadata-from-file=startup-script=startup-script.sh \
  --tags=http-server

# Create unmanaged instance group
echo "Creating unmanaged instance group..."
gcloud compute instance-groups unmanaged create $INSTANCE_GROUP --zone=$ZONE

# Set named ports in unmanaged instance group
echo "Setting named ports..."
gcloud compute instance-groups unmanaged set-named-ports $INSTANCE_GROUP \
   --zone=$ZONE \
   --named-ports=server-port:80

# Assign VM instances to unmanaged instance group
echo "Adding VM instances to unmanaged instance group..."
gcloud compute instance-groups unmanaged add-instances $INSTANCE_GROUP \
   --zone=$ZONE \
   --instances=$INSTANCE1,$INSTANCE2

# Create health check with updated parameters (Regional Health Check)
echo "Creating health check..."
gcloud compute health-checks create http $HEALTH_CHECK_NAME \
   --port=80 \
   --request-path=/index.html \
   --proxy-header=NONE \
   --region=$REGION \
   --no-enable-logging \
   --check-interval=10s \
   --timeout=5s \
   --unhealthy-threshold=3 \
   --healthy-threshold=2

# Create firewall rule for Google health check
echo "Creating firewall rule for health check..."
gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
   --allow=tcp:80 \
   --source-ranges=130.211.0.0/22,35.191.0.0/16 \
   --network=default \
   --target-tags=http-server

# Reserve a global external static IP address
echo "Reserving a global external static IP address..."
gcloud compute addresses create $STATIC_IP_NAME \
   --region us-central1 --network-tier=Standard

# Get the reserved static IP address
STATIC_IP=$(gcloud compute addresses describe $STATIC_IP_NAME --global --format="get(address)")

# Print the assigned static IP address
echo -e "\n\033[1;32mLoad Balancer is set up with the following static IP address: $STATIC_IP\033[0m\n"

echo "Resource creation complete."
