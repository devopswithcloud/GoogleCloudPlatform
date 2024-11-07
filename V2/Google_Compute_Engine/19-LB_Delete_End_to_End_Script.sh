#!/bin/bash

# Delete the forwarding rule
gcloud compute forwarding-rules delete i27-global-lb-forwarding-rule --global --quiet

# Delete the target HTTP proxy
gcloud compute target-http-proxies delete i27-global-lb-http-proxy --quiet

# Delete the URL map
gcloud compute url-maps delete i27-global-lb-url-map-alb --quiet

# Delete the backend service
gcloud compute backend-services delete i27-global-lb-backend-service --global --quiet

# Delete the static external IP address
gcloud compute addresses delete i27-global-lb-ip --global --quiet

# Remove named ports from managed instance groups
gcloud compute instance-groups managed set-named-ports i27-global-lb-central-mig --named-ports= --region=us-central1 --quiet
gcloud compute instance-groups managed set-named-ports i27-global-lb-singapore-mig --named-ports= --region=asia-southeast1 --quiet

# Delete managed instance groups
gcloud compute instance-groups managed delete i27-global-lb-central-mig --region=us-central1 --quiet
gcloud compute instance-groups managed delete i27-global-lb-singapore-mig --region=asia-southeast1 --quiet

# Delete health check
gcloud compute health-checks delete i27-global-lb-health-check --global --quiet

# Delete instance templates
gcloud compute instance-templates delete i27-global-lb-central-instance-template --region us-central1 --quiet
gcloud compute instance-templates delete i27-global-lb-singapore-instance-template --region asia-southeast1 --quiet

# Delete firewall rules
gcloud compute firewall-rules delete i27-allow-ssh-http-icmp --quiet
gcloud compute firewall-rules delete i27-allow-health-checks --quiet

# Delete subnets
gcloud compute networks subnets delete i27-global-lb-us-central1-subnet --region=us-central1 --quiet
gcloud compute networks subnets delete i27-global-lb-asia-southeast1-subnet --region=asia-southeast1 --quiet

# Delete the VPC network
gcloud compute networks delete i27-global-lb-vpc --quiet

echo "All resources have been deleted."
