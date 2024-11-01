
### **Guide for Setting up a Managed Instance Group (MIG) on Google Cloud Platform**

#### **In this guide, you will create:**

- **Startup Script (`startupscript-v1.sh`)**: A script to configure instances with `telnet` and `nginx` and a custom HTML page.
- **Instance Template (`i27-managed-instance-template-v1`)**: Configures VM settings such as machine type, startup script, and network tags.
- **Firewall Rule (`allow-http-server`)**: Allows HTTP traffic on port 80 for instances tagged as `http-server`.
- **Health Check (`i27-mig-health-check`)**: Monitors instance health for automatic repair and scaling decisions.
- **Managed Instance Group (`i27-mig-v1`)**:
  - **Autoscaling**: Set with minimum and maximum instances, scaling based on CPU utilization.
  - **Autohealing**: Uses the health check to automatically repair unhealthy instances.
  - **Port Mapping**: Maps port `80` for HTTP traffic.

---

### **Step-by-Step Guide for Setting Up the Managed Instance Group (MIG)**

---

### **1. Create the Startup Script (startupscript-v1.sh)**

1. **Create the Script File**:
   - Save the following script as `startupscript-v1.sh`.
   - This script installs `telnet` and `nginx`, starts the Nginx service, and creates a custom HTML page displaying the server’s hostname, IP address, and version.

   ```bash
   #!/bin/bash
   # Install necessary packages
   sudo apt install -y telnet
   sudo apt install -y nginx

   # Enable and start Nginx
   sudo systemctl enable nginx
   sudo chmod -R 755 /var/www/html

   # Get hostname
   HOSTNAME=$(hostname)

   # Create the HTML file with custom styling and version details
   sudo echo "<!DOCTYPE html>
   <html>
   <head>
       <style>
           body {
               background-color: #004d40;
               color: #ffffff;
               font-family: 'Arial', sans-serif;
               text-align: center;
               padding: 50px;
               margin: 0;
           }
           h1 {
               color: #ffab00;
               font-size: 2.5em;
               margin-bottom: 20px;
           }
           p {
               font-size: 1.2em;
               margin: 10px 0;
           }
           .hostname {
               color: #ffccbc;
           }
           .ip-address {
               color: #80deea;
           }
           .version {
               color: #ff5722;
               font-weight: bold;
               font-size: 1.5em;
               margin-top: 30px;
           }
           strong {
               color: #e0f2f1;
           }
       </style>
   </head>
   <body>
       <h1>i27academy Google Cloud Platform</h1>
       <p><strong class="hostname">Server Hostname:</strong> ${HOSTNAME}</p>
       <p><strong class="ip-address">Server IP Address:</strong> $(hostname -I)</p>
       <p class="version">Version-1</p>
   </body>
   </html>" | sudo tee /var/www/html/index.html
   ```

---

### **2. Create an Instance Template Using gcloud**

We can create an instance template using the **Google Cloud Console** or via `gcloud` CLI. Here’s how:

#### **Console Steps**

1. **Navigate to Compute Engine** > **Instance Templates**.
2. **Click Create Instance Template**.
3. Configure the following settings:
   - **Name**: Enter `i27-managed-instance-template-v1`.
   - **Machine Type**: Select `e2-medium`.
   - **Network Tags**: Enter `http-server`.
   - **Startup Script**: Upload the file `startupscript-v1.sh`.
   - **Region**: Choose `us-central1`.

4. **Save and create the template**.

#### **gcloud Command for Instance Template**

   ```bash
   gcloud compute instance-templates create i27-managed-instance-template-v1 \
       --machine-type=e2-medium \
       --network-interface=network=default,network-tier=PREMIUM \
       --tags=http-server \
       --metadata-from-file=startup-script=startupscript-v1.sh \
       --instance-template-region=us-central1
   ```

---

### **3. Create Firewall Rule to Allow HTTP Access on Port 80**

1. **Create Firewall Rule for HTTP Traffic**:
   - Run the following command to allow inbound HTTP traffic on port 80 for instances with the `http-server` tag.

   ```bash
   gcloud compute firewall-rules create allow-http-server \
       --project=criticalproject \
       --direction=INGRESS \
       --priority=1000 \
       --network=default \
       --action=ALLOW \
       --rules=tcp:80 \
       --source-ranges=0.0.0.0/0 \
       --target-tags=http-server \
       --description="Allow inbound HTTP traffic on port 80 for instances with the http-server tag"
   ```

---

### **4. Configure the Managed Instance Group with Health Checks and Autoscaling**

---

#### **Console Steps for MIG Creation**

1. **Navigate to Compute Engine** > **Instance Groups**.
2. **Create New Managed Instance Group**.
3. **Configure Group Settings**:
   - **Name**: `i27-mig-v1`
   - **Instance Template**: Select `i27-managed-instance-template-v1`.
   - **Location**: **Single zone** `us-central1-c`.
4. **Autoscaling Settings**:
   - **Autoscaling Mode**: Set to **On**.
   - **Minimum Number of Instances**: `2`.
   - **Maximum Number of Instances**: `3`.
   - **CPU Utilization**: `60%`.
5. **Initialization Period**: Set to `60 seconds`.
6. **Scale-In Controls**: Limit scale-in to `1 VM` over `10 minutes`.
7. **VM Instance Lifecycle**: Set to **Repair Instance**.
8. **Autohealing Configuration**:
   - **Health Check**:
     - **Name**: `i27-mig-health-check`
     - **Scope**: Regional
     - **Protocol**: HTTP, request path `/`.
9. **Port Name Mapping**: 
   - **Port Name**: `i27-web-port`
   - **Port Number**: `80`.
10. **Click Create** to finalize the group setup.

### **gcloud Commands for MIG Configuration**

1. **Create the Health Check**:
   ```bash
   gcloud beta compute health-checks create http i27-mig-health-check \
       --project=criticalproject \
       --port=80 \
       --request-path=/ \
       --proxy-header=NONE \
       --no-enable-logging \
       --check-interval=5 \
       --timeout=5 \
       --unhealthy-threshold=2 \
       --healthy-threshold=2
   ```

2. **Create the Managed Instance Group**:
   ```bash
   gcloud beta compute instance-groups managed create i27-mig-v1 \
       --project=criticalproject \
       --base-instance-name=i27-mig-v1 \
       --template=projects/criticalproject/regions/us-central1/instanceTemplates/i27-managed-instance-template-v1 \
       --size=1 \
       --zone=us-central1-c \
       --default-action-on-vm-failure=repair \
       --health-check=projects/criticalproject/global/healthChecks/i27-mig-health-check \
       --initial-delay=300 \
       --no-force-update-on-repair \
       --standby-policy-mode=manual \
       --list-managed-instances-results=pageless
   ```

3. **Set Autoscaling Configuration**:
   ```bash
   gcloud beta compute instance-groups managed set-autoscaling i27-mig-v1 \
       --project=criticalproject \
       --zone=us-central1-c \
       --mode=on \
       --min-num-replicas=2 \
       --max-num-replicas=3 \
       --target-cpu-utilization=0.6 \
       --cpu-utilization-predictive-method=none \
       --cool-down-period=60 \
       --scale-in-control=max-scaled-in-replicas=1,time-window=600
   ```

4. **Set Named Port for the Instance Group**:
   ```bash
   gcloud compute instance-groups set-named-ports i27-mig-v1 \
       --project=criticalproject \
       --zone=us-central1-c \
       --named-ports=i27-web-port:80
   ```

---

### **Commands to Delete Resources Created**

After the MIG is set up and tested, you can clean up by deleting all the resources created.

1. **Delete the Managed Instance Group (MIG)**:
   ```bash
   gcloud beta compute instance-groups managed delete i27-mig-v1 \
       --project=criticalproject \
       --zone=us-central1-c \
       --quiet
   ```

2. **Delete the Health Check**:
   ```bash
   gcloud beta compute health-checks delete i27-mig-health-check \
       --project=criticalproject \
       --quiet
   ```

3. **Delete the Instance Template**:
   ```bash
   gcloud compute instance-templates delete i27-managed-instance-template-v1 \
       --project=criticalproject \
       --quiet \
       --region=us-central1
   ```

4. **Delete the Firewall Rule**:
   ```bash
   gcloud compute firewall-rules delete allow-http-server \
       --project=criticalproject \
       --quiet
   ```

---

### **Summary of Configuration**

- **Managed Instance Group Name**: `i27-mig-v1`
- **Instance Template**: `i27-managed-instance-template-v1`
- **Location**: `us-central1-c`
- **Autoscaling**: On, min `2`, max `3`, CPU utilization `60%`.
- **Initialization Period**: `60 seconds`
- **Scale-In Control**: Limit to `1 VM` over `10 minutes`.
- **Default Failure Action**: **Repair Instance**
- **Autohealing**: **i27-mig-health-check** with HTTP on path `/`.
- **Port Mapping**: `i27-web-port` to port `80`.

