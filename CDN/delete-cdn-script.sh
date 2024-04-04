#!/bin/bash

# Delete the testing instance in us-central1 region
gcloud compute instances delete testing-instance --zone us-central1-b --quiet
echo "Deleted testing instance"

# Delete the global forwarding rule, target HTTP proxy, and URL map
gcloud compute forwarding-rules delete http-frontend --global --quiet
gcloud compute target-http-proxies delete http-lb-proxy --quiet
gcloud compute url-maps delete http-lb --quiet

echo "Deleted Forwarding rules, target http proxy, url map"

# Delete the backend service and its backends
gcloud compute backend-services delete http-backend --global --quiet
echo "Deleted backend service"

# Delete Instance Groups
gcloud compute instance-groups managed delete australia-southeast1-group --region australia-southeast1 --quiet
echo "Deleted Instance Groups"


# Delete the health check
gcloud compute health-checks delete health-check --quiet
echo "Deleted health check"

# Delete the firewall rules
gcloud compute firewall-rules delete health-check-allow --quiet
gcloud compute firewall-rules delete http-allow --quiet
echo "Deleted Firewall rules"


# Delete the instance template
gcloud compute instance-templates delete cdn-demo-template --quiet
echo "Deleted Instance Template"
