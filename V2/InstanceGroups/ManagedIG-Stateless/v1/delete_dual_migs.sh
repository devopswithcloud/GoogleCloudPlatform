#!/bin/bash

# This script performs the following actions:
# 1. Deletes the forwarding rule.
# 2. Deletes the target HTTP proxy.
# 3. Deletes the URL map.
# 4. Deletes the backend service.
# 5. Deletes the proxy-only subnet.
# 6. Deletes the managed instance group.
# 7. Deletes the firewall rule.
# 8. Deletes the health check.
# 9. Deletes the instance template.
# 10. Deletes the static external IP address.
# 11. Deletes the startup script file.

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
INSTANCE_GROUP="unmanaged-group-1"
STATIC_IP_NAME="lb-static-ip"
SUBNET_NAME="prox-only-subnet"
MANAGED_INSTANCE_GROUP_NAME_1="central-mig"
MANAGED_INSTANCE_GROUP_NAME_2="singapore-mig"
BACKEND_SERVICE_NAME="mig-backend-service"
URL_MAP_NAME="mig-lb"
TARGET_HTTP_PROXY_NAME="mig-lb-target-proxy"
FORWARDING_RULE_NAME="mig-lb-forwarding-rule"

# Delete global forwarding rule
if gcloud compute forwarding-rules describe $FORWARDING_RULE_NAME --global --quiet > /dev/null 2>&1; then
    echo "Deleting forwarding rule $FORWARDING_RULE_NAME..."
    gcloud compute forwarding-rules delete $FORWARDING_RULE_NAME --global --quiet
fi

# Delete target HTTP proxy
if gcloud compute target-http-proxies describe $TARGET_HTTP_PROXY_NAME --global --quiet > /dev/null 2>&1; then
    echo "Deleting target HTTP proxy $TARGET_HTTP_PROXY_NAME..."
    gcloud compute target-http-proxies delete $TARGET_HTTP_PROXY_NAME --global --quiet
fi

# Delete URL map
if gcloud compute url-maps describe $URL_MAP_NAME --global --quiet > /dev/null 2>&1; then
    echo "Deleting URL map $URL_MAP_NAME..."
    gcloud compute url-maps delete $URL_MAP_NAME --global --quiet
fi

# Delete backend service
if gcloud compute backend-services describe $BACKEND_SERVICE_NAME --global --quiet > /dev/null 2>&1; then
    echo "Deleting backend service $BACKEND_SERVICE_NAME..."
    gcloud compute backend-services delete $BACKEND_SERVICE_NAME --global --quiet
fi

# Delete proxy-only subnet
if gcloud compute networks subnets describe $SUBNET_NAME --region=$REGION --quiet > /dev/null 2>&1; then
    echo "Deleting subnet $SUBNET_NAME..."
    gcloud compute networks subnets delete $SUBNET_NAME --region=$REGION --quiet
fi

# Delete managed instance group 1
if gcloud compute instance-groups managed describe $MANAGED_INSTANCE_GROUP_NAME_1 --zone=$ZONE_1 --quiet > /dev/null 2>&1; then
    echo "Deleting managed instance group $MANAGED_INSTANCE_GROUP_NAME_1 ..."
    gcloud compute instance-groups managed delete $MANAGED_INSTANCE_GROUP_NAME_1 --zone=$ZONE_1 --quiet
fi

# Delete managed instance group 2
if gcloud compute instance-groups managed describe $MANAGED_INSTANCE_GROUP_NAME_2 --zone=$ZONE_2 --quiet > /dev/null 2>&1; then
    echo "Deleting managed instance group $MANAGED_INSTANCE_GROUP_NAME_2 ..."
    gcloud compute instance-groups managed delete $MANAGED_INSTANCE_GROUP_NAME_2 --zone=$ZONE_2 --quiet
fi


# Delete firewall rule
if gcloud compute firewall-rules describe $FIREWALL_RULE_NAME --quiet > /dev/null 2>&1; then
    echo "Deleting firewall rule $FIREWALL_RULE_NAME..."
    gcloud compute firewall-rules delete $FIREWALL_RULE_NAME --quiet
fi

# Delete health check 1
if gcloud compute health-checks describe $HEALTH_CHECK_NAME --region=$REGION_1 --quiet > /dev/null 2>&1; then
    echo "Deleting health check $HEALTH_CHECK_NAME..."
    gcloud compute health-checks delete $HEALTH_CHECK_NAME --region=$REGION_1 --quiet
fi

# Delete health check 2
if gcloud compute health-checks describe $HEALTH_CHECK_NAME --region=$REGION_2 --quiet > /dev/null 2>&1; then
    echo "Deleting health check $HEALTH_CHECK_NAME..."
    gcloud compute health-checks delete $HEALTH_CHECK_NAME --region=$REGION_2 --quiet
fi

# Delete Global health check
if gcloud compute health-checks describe $HEALTH_CHECK_NAME --global --quiet > /dev/null 2>&1; then
    echo "Deleting health check $HEALTH_CHECK_NAME..."
    gcloud compute health-checks delete $HEALTH_CHECK_NAME --global --quiet
fi


# Delete instance template
if gcloud compute instance-templates describe $INSTANCE_TEMPLATE_NAME --quiet > /dev/null 2>&1; then
    echo "Deleting instance template $INSTANCE_TEMPLATE_NAME..."
    gcloud compute instance-templates delete $INSTANCE_TEMPLATE_NAME --quiet
fi

# Delete static IP address
if gcloud compute addresses describe $STATIC_IP_NAME --global --quiet > /dev/null 2>&1; then
    echo "Deleting static IP address $STATIC_IP_NAME..."
    gcloud compute addresses delete $STATIC_IP_NAME --global --quiet
fi

# Cleanup startup script file
if [ -f $STARTUP_SCRIPT ]; then
    echo "Cleaning up startup script file..."
    rm -f $STARTUP_SCRIPT
fi

echo "Script execution completed."
