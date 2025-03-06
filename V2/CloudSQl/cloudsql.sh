

# Create a cloudsql instance 
gcloud sql instances create boutique-central \
    --database-version="MYSQL_8_0" \
    --region us-central1 \
    --edition "enterprise" \
    --availability-type "REGIONAL" \
    --storage-type "SSD" \
    --storage-size "10" \
    --cpu "1" \
    --memory 3840MiB \
    --enable-bin-log


# Create a database 
gcloud sql databases create boutique \
    --instance boutique-central

# Create a user 
gcloud sql users create boutique-user \
    --instance boutique-central \
    --password boutique
    --host '%'

# Replciate a zonal failover within a region, and a failover will happen in other zone (in same region)
gcloud sql instances failover boutique-central

# ********************************************** EnterprisePlus **********************************************
# Create a cloudsql instance in us-central1
gcloud sql instances create boutique-central \
    --database-version="MYSQL_8_0" \
    --region us-central1 \
    --edition "enterprise-plus" \
    --availability-type "REGIONAL" \
    --storage-type "SSD" \
    --storage-size "10" \
    --tier db-perf-optimized-N-2 \
    --enable-bin-log

# Create a database
gcloud sql databases create boutique \
    --instance boutique-central

# Create a user
gcloud sql users create boutique-user \
    --instance boutique-central \
    --password boutique \
    --host '%'

# Create a read replica in us-east4
gcloud sql instances create boutique-east \
    --region us-east4 \
    --master-instance-name boutique-central \
    --tier db-perf-optimized-N-2 \
    --availability-type "zonal" \
    --edition "enterprise-plus"

gcloud sql instances delete boutique-central
gcloud sql instances delete boutique-east
