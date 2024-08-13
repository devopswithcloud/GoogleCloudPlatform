#!/bin/bash

# Variables
ZONE="us-central1-a"
REGION="us-central1"
INSTANCE1="instance-1"
INSTANCE2="instance-2"
INSTANCE_GROUP="unmanaged-group-1"
HEALTH_CHECK_NAME="health-check"
FIREWALL_RULE_NAME="allow-health-check"
STATIC_IP_NAME="lb-static-ip"
STARTUP_SCRIPT="startup-script.sh"

# Check and delete the health check
if gcloud compute health-checks describe $HEALTH_CHECK_NAME --region=$REGION --quiet > /dev/null 2>&1; then
    echo "Deleting health check..."
    gcloud compute health-checks delete $HEALTH_CHECK_NAME --region=$REGION --quiet
else
    echo "Health check $HEALTH_CHECK_NAME not found."
fi

# Check and delete the firewall rule
if gcloud compute firewall-rules describe $FIREWALL_RULE_NAME --quiet > /dev/null 2>&1; then
    echo "Deleting firewall rule..."
    gcloud compute firewall-rules delete $FIREWALL_RULE_NAME --quiet
else
    echo "Firewall rule $FIREWALL_RULE_NAME not found."
fi

# Check and delete the unmanaged instance group
if gcloud compute instance-groups unmanaged describe $INSTANCE_GROUP --zone=$ZONE --quiet > /dev/null 2>&1; then
    echo "Deleting unmanaged instance group..."
    gcloud compute instance-groups unmanaged delete $INSTANCE_GROUP --zone=$ZONE --quiet
else
    echo "Instance group $INSTANCE_GROUP not found."
fi

# Check and delete the VM instances
if gcloud compute instances describe $INSTANCE1 --zone=$ZONE --quiet > /dev/null 2>&1 && \
   gcloud compute instances describe $INSTANCE2 --zone=$ZONE --quiet > /dev/null 2>&1; then
    echo "Deleting VM instances..."
    gcloud compute instances delete $INSTANCE1 $INSTANCE2 --zone=$ZONE --quiet
else
    echo "VM instances $INSTANCE1 and/or $INSTANCE2 not found."
fi

# Check and release the global static IP address
if gcloud compute addresses describe $STATIC_IP_NAME --global --quiet > /dev/null 2>&1; then
    echo "Releasing static IP address..."
    gcloud compute addresses delete $STATIC_IP_NAME --global --quiet
else
    echo "Static IP address $STATIC_IP_NAME not found."
fi

# Delete the startup script file
echo "Deleting the startup script file..."
rm -f $STARTUP_SCRIPT

echo "Resource and file deletion complete."

