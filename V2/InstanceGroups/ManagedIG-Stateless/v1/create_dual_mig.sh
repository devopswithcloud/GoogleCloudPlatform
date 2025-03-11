#!/bin/bash

# 1. Creates a startup script for VM instances.
# 2. Checks and creates a static external IP address, and prints it.
# 3. firewall rule to allow HTTP traffic.
# 4. Checks and creates an instance template with the provided startup script.
# 5. Checks and creates a health check for the load balancer.
# 6. Checks and creates a fi This script performs the following actions:
# 7. Checks and creates 2 managed instance groups with autoscaling.
# 8. Sets named ports for the managed instance group.
# 9. Checks and creates a regional managed proxy subnet.
# 10. Creates a backend service.
# 11. Creates a URL map.
# 12. Creates a target HTTP proxy.
# 13. Creates a global forwarding rule.
# 14. Cleans up the startup script file.

# Fetch the current project ID from gcloud config
PROJECT_ID=$(gcloud config get-value project --quiet)

# Check if PROJECT_ID is empty
if [ -z "$PROJECT_ID" ]; then
  echo "No project ID is set in gcloud config. Please set the project ID and try again."
  exit 1
fi

# Variables
REGION="us-central1"
REGION_1="us-central1"
ZONE_1="us-central1-a"
REGION_2="asia-southeast1"
ZONE_2="asia-southeast1-a"
STARTUP_SCRIPT="startup-script.sh"
INSTANCE_TEMPLATE_NAME="instance-template-v1"
HEALTH_CHECK_NAME="health-check"
FIREWALL_RULE_NAME="allow-health-check"
INSTANCE_GROUP_1="unmanaged-group-1"
PORT_NUMBER="80"
NAMED_PORT="mig-named-port"
STATIC_IP_NAME="lb-static-ip"
SUBNET_NAME="prox-only-subnet"
SUBNET_RANGE="10.0.0.0/24"
SUBNET_PURPOSE="REGIONAL_MANAGED_PROXY"
SUBNET_ROLE="ACTIVE"
MANAGED_INSTANCE_GROUP_NAME_1="central-mig"
MANAGED_INSTANCE_GROUP_NAME_2="singapore-mig"
BACKEND_SERVICE_NAME="mig-backend-service"
URL_MAP_NAME="mig-lb"
TARGET_HTTP_PROXY_NAME="mig-lb-target-proxy"
FORWARDING_RULE_NAME="mig-lb-forwarding-rule"

# Define updated startup script content
STARTUP_SCRIPT_CONTENT=$(cat <<EOF
#!/bin/bash
sudo apt install -y telnet
sudo apt install -y nginx
sudo systemctl enable nginx
sudo chmod -R 755 /var/www/html
HOSTNAME=\$(hostname)
sudo echo "<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            background-color: #004d40; /* Dark teal background */
            color: #ffffff; /* White text */
            font-family: 'Arial', sans-serif; /* Clean and modern font */
            text-align: center; /* Center align text */
            padding: 50px; /* Add padding around the content */
            margin: 0;
        }
        h1 {
            color: #ffab00; /* Bright amber color for the header */
            font-size: 2.5em; /* Larger font size for header */
            margin-bottom: 20px;
        }
        p {
            font-size: 1.2em; /* Slightly larger font size for paragraph */
            margin: 10px 0;
        }
        .hostname {
            color: #ffccbc; /* Soft peach color for hostname */
        }
        .ip-address {
            color: #80deea; /* Light cyan color for IP address */
        }
        .version {
            color: #ff5722; /* Vibrant orange color for version text */
            font-weight: bold; /* Bold text */
            font-size: 1.5em; /* Larger font size for version */
            margin-top: 30px; /* Add space above version text */
        }
        strong {
            color: #e0f2f1; /* Light teal color for strong text */
        }
    </style>
</head>
<body>
    <h1>i27academy Google Cloud Platform</h1>
    <p><strong class="hostname">Server Hostname:</strong> \${HOSTNAME}</p>
    <p><strong class="ip-address">Server IP Address:</strong> \$(hostname -I)</p>
    <p class="version">Version-1</p>
</body>
</html>" | sudo tee /var/www/html/index.html
EOF
)

# Create startup script file
echo "Creating startup script file..."
echo "$STARTUP_SCRIPT_CONTENT" > $STARTUP_SCRIPT
chmod +x $STARTUP_SCRIPT

# Check and create static IP address
if gcloud compute addresses describe $STATIC_IP_NAME --global --quiet > /dev/null 2>&1; then
    echo "Static IP address $STATIC_IP_NAME already exists."
else
    echo "Reserving external static IP address..."
    gcloud compute addresses create $STATIC_IP_NAME --global
fi

# Retrieve and print the static IP address
STATIC_IP=$(gcloud compute addresses describe $STATIC_IP_NAME --global --format='value(address)')
if [ -z "$STATIC_IP" ]; then
    echo "Failed to retrieve the static IP address."
    exit 1
else
    echo -e "\nThe static IP address assigned to the load balancer frontend is: \033[1;32m$STATIC_IP\033[0m"
fi

# Check and create instance template
if gcloud compute instance-templates describe $INSTANCE_TEMPLATE_NAME --quiet > /dev/null 2>&1; then
    echo "Instance template $INSTANCE_TEMPLATE_NAME already exists."
else
    echo "Creating instance template..."
    gcloud compute instance-templates create $INSTANCE_TEMPLATE_NAME \
       --machine-type=e2-micro \
       --no-address \
       --network-interface=network=default,network-tier=PREMIUM,no-address \
       --tags=http-server \
       --metadata-from-file=startup-script=$STARTUP_SCRIPT
fi

# Check and create global health check
if gcloud compute health-checks describe $HEALTH_CHECK_NAME --global --quiet > /dev/null 2>&1; then
    echo "Health check $HEALTH_CHECK_NAME already exists."
else
    echo "Creating health check..."
    gcloud compute health-checks create http $HEALTH_CHECK_NAME \
       --port=80 \
       --request-path=/index.html \
       --proxy-header=NONE \
       --global \
       --no-enable-logging \
       --check-interval=10s \
       --timeout=5s \
       --unhealthy-threshold=3 \
       --healthy-threshold=2
fi

# Check and create health check 1
if gcloud compute health-checks describe $HEALTH_CHECK_NAME --region=$REGION_1 --quiet > /dev/null 2>&1; then
    echo "Health check $HEALTH_CHECK_NAME already exists."
else
    echo "Creating health check..."
    gcloud compute health-checks create http $HEALTH_CHECK_NAME \
       --port=80 \
       --request-path=/index.html \
       --proxy-header=NONE \
       --region=$REGION_1 \
       --no-enable-logging \
       --check-interval=10s \
       --timeout=5s \
       --unhealthy-threshold=3 \
       --healthy-threshold=2
fi

# Check and create health check 2
if gcloud compute health-checks describe $HEALTH_CHECK_NAME --region=$REGION_2 --quiet > /dev/null 2>&1; then
    echo "Health check $HEALTH_CHECK_NAME already exists."
else
    echo "Creating health check..."
    gcloud compute health-checks create http $HEALTH_CHECK_NAME \
       --port=80 \
       --request-path=/index.html \
       --proxy-header=NONE \
       --region=$REGION_2 \
       --no-enable-logging \
       --check-interval=10s \
       --timeout=5s \
       --unhealthy-threshold=3 \
       --healthy-threshold=2
fi



# Check and create firewall rule
if gcloud compute firewall-rules describe $FIREWALL_RULE_NAME --quiet > /dev/null 2>&1; then
    echo "Firewall rule $FIREWALL_RULE_NAME already exists."
else
    echo "Creating firewall rule for health check..."
    gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
       --allow=tcp:80 \
       --source-ranges=130.211.0.0/22,35.191.0.0/16 \
       --network=default \
       --target-tags=http-server
fi

# Check and create managed instance group_1 
if gcloud compute instance-groups managed describe $MANAGED_INSTANCE_GROUP_NAME_1 --zone=$ZONE_1 --quiet > /dev/null 2>&1; then
    echo "Managed instance group $MANAGED_INSTANCE_GROUP_NAME_1 already exists."
else
    echo "Creating managed instance group..."
    gcloud beta compute instance-groups managed create $MANAGED_INSTANCE_GROUP_NAME_1 \
        --base-instance-name=$MANAGED_INSTANCE_GROUP_NAME_1 \
        --template=projects/$PROJECT_ID/global/instanceTemplates/$INSTANCE_TEMPLATE_NAME \
        --size=2 \
        --zone=$ZONE_1 \
        --default-action-on-vm-failure=repair \
        --health-check=projects/$PROJECT_ID/regions/$REGION_1/healthChecks/$HEALTH_CHECK_NAME \
        --initial-delay=300 \
        --no-force-update-on-repair \
        --standby-policy-mode=manual \
        --list-managed-instances-results=PAGELESS

    # Set autoscaling for the managed instance group
    echo "Setting autoscaling for the managed instance group..."
    gcloud beta compute instance-groups managed set-autoscaling $MANAGED_INSTANCE_GROUP_NAME_1 \
        --zone=$ZONE_1 \
        --mode=on \
        --min-num-replicas=2 \
        --max-num-replicas=3 \
        --target-cpu-utilization=0.6 \
        --cool-down-period=60
fi


# Check and create managed instance group_2 
if gcloud compute instance-groups managed describe $MANAGED_INSTANCE_GROUP_NAME_2 --zone=$ZONE_2 --quiet > /dev/null 2>&1; then
    echo "Managed instance group $MANAGED_INSTANCE_GROUP_NAME_2 already exists."
else
    echo "Creating managed instance group..."
    gcloud beta compute instance-groups managed create $MANAGED_INSTANCE_GROUP_NAME_2 \
        --base-instance-name=$MANAGED_INSTANCE_GROUP_NAME_2 \
        --template=projects/$PROJECT_ID/global/instanceTemplates/$INSTANCE_TEMPLATE_NAME \
        --size=2 \
        --zone=$ZONE_2 \
        --default-action-on-vm-failure=repair \
        --health-check=projects/$PROJECT_ID/regions/$REGION_2/healthChecks/$HEALTH_CHECK_NAME \
        --initial-delay=300 \
        --no-force-update-on-repair \
        --standby-policy-mode=manual \
        --list-managed-instances-results=PAGELESS

    # Set autoscaling for the managed instance group
    echo "Setting autoscaling for the managed instance group..."
    gcloud beta compute instance-groups managed set-autoscaling $MANAGED_INSTANCE_GROUP_NAME_2 \
        --zone=$ZONE_2 \
        --mode=on \
        --min-num-replicas=2 \
        --max-num-replicas=3 \
        --target-cpu-utilization=0.6 \
        --cool-down-period=60
fi



# Check and set named ports for the managed instance group_1
NAMED_PORTS_SET=$(gcloud compute instance-groups managed describe $MANAGED_INSTANCE_GROUP_NAME_1 \
    --zone=$ZONE_1 --format="get(namedPorts)" --quiet)

if echo "$NAMED_PORTS_SET" | grep -q "$NAMED_PORT"; then
    echo "Named port $NAMED_PORT is already set for the managed instance group $MANAGED_INSTANCE_GROUP_NAME_1."
else
    echo "Setting named ports for the managed instance group..."
    gcloud compute instance-groups managed set-named-ports $MANAGED_INSTANCE_GROUP_NAME_1 \
        --zone=$ZONE_1 \
        --named-ports=$NAMED_PORT:$PORT_NUMBER
fi


# Check and set named ports for the managed instance group_2
NAMED_PORTS_SET=$(gcloud compute instance-groups managed describe $MANAGED_INSTANCE_GROUP_NAME_2 \
    --zone=$ZONE_2 --format="get(namedPorts)" --quiet)

if echo "$NAMED_PORTS_SET" | grep -q "$NAMED_PORT"; then
    echo "Named port $NAMED_PORT is already set for the managed instance group $MANAGED_INSTANCE_GROUP_NAME_2."
else
    echo "Setting named ports for the managed instance group..."
    gcloud compute instance-groups managed set-named-ports $MANAGED_INSTANCE_GROUP_NAME_2 \
        --zone=$ZONE_2 \
        --named-ports=$NAMED_PORT:$PORT_NUMBER
fi



# Check and create proxy-only subnet
#if gcloud compute networks subnets describe $SUBNET_NAME --region=$REGION --quiet > /dev/null 2>&1; then
#   echo "Subnet $SUBNET_NAME already exists."
#else
#    echo "Creating subnet $SUBNET_NAME..."
#    gcloud compute networks subnets create $SUBNET_NAME \
#        --purpose=$SUBNET_PURPOSE \
#        --role=$SUBNET_ROLE \
#        --region=$REGION \
#        --network=default \
#        --range=$SUBNET_RANGE
#fi

# Create backend service
if gcloud compute backend-services describe $BACKEND_SERVICE_NAME --region=$REGION --quiet > /dev/null 2>&1; then
    echo "Backend service $BACKEND_SERVICE_NAME already exists."
else
    echo "Creating backend service..."
    gcloud compute backend-services create $BACKEND_SERVICE_NAME \
        --project=$PROJECT_ID \
        --global \
        --port-name=$NAMED_PORT \
        --protocol=HTTP \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --locality-lb-policy=ROUND_ROBIN \
        --connection-draining-timeout=300 \
        --session-affinity=NONE \
        --timeout=30
fi

# Update Health Check to Backend service
echo "Updating health check for backend service..."
gcloud compute backend-services update $BACKEND_SERVICE_NAME \
    --global-health-checks \
    --health-checks=$HEALTH_CHECK_NAME \
    --global

# Add backend_1 to backend service
echo "Adding backend 1 to backend service..."
gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
    --instance-group=$MANAGED_INSTANCE_GROUP_NAME_1 \
    --instance-group-zone=$ZONE_1 \
    --balancing-mode=UTILIZATION \
    --global

# Add backend_2 to backend service
echo "Adding backend 2 to backend service..."
gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
    --instance-group=$MANAGED_INSTANCE_GROUP_NAME_2 \
    --instance-group-zone=$ZONE_2 \
    --balancing-mode=UTILIZATION \
    --global

# Create URL map
if gcloud compute url-maps describe $URL_MAP_NAME --global --quiet > /dev/null 2>&1; then
    echo "URL map $URL_MAP_NAME already exists."
else
    echo "Creating URL map..."
    gcloud compute url-maps create $URL_MAP_NAME \
        --project=$PROJECT_ID \
        --default-service=projects/$PROJECT_ID/global/backendServices/$BACKEND_SERVICE_NAME \
        --global
fi

# Create target HTTP proxy
if gcloud compute target-http-proxies describe $TARGET_HTTP_PROXY_NAME --global --quiet > /dev/null 2>&1; then
    echo "Target HTTP proxy $TARGET_HTTP_PROXY_NAME already exists."
else
    echo "Creating target HTTP proxy..."
    gcloud compute target-http-proxies create $TARGET_HTTP_PROXY_NAME \
        --project=$PROJECT_ID \
        --url-map=projects/$PROJECT_ID/global/urlMaps/$URL_MAP_NAME \
        --global-url-map \
        --global
fi

# Create global forwarding rule
if gcloud compute forwarding-rules describe $FORWARDING_RULE_NAME --global --quiet > /dev/null 2>&1; then
    echo "Forwarding rule $FORWARDING_RULE_NAME already exists."
else
    echo "Creating forwarding rule..."
    gcloud compute forwarding-rules create $FORWARDING_RULE_NAME \
        --project=$PROJECT_ID \
        --global \
        --ip-protocol=TCP \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --network-tier=PREMIUM \
        --ports=80 \
        --address=$STATIC_IP_NAME \
        --global-target-https-proxy \
        --target-http-proxy=$TARGET_HTTP_PROXY_NAME
fi

# Cleanup startup script file
echo "Cleaning up startup script file..."
rm -f $STARTUP_SCRIPT


echo -------------------------------
echo "Script complete, wait about 5 minutes for your load balancer to initialize, then access frontend address in a new tab"
echo -e "\nYour load balancer frontend IP address is: \033[1;32m$STATIC_IP\033[0m"
echo "If you receive an error for the website, wait a few more minutes and try again"
echo -------------------------------

echo "Script execution completed."
