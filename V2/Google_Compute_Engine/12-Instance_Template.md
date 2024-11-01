## Instance Template Using CLI
* This will create a startup script
* Based on the startup script , a instance template will be created 


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

### **2. Create an Instance Template Using Console**

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

### **3. Create an Instance Template Using gcloud**

   ```bash
   gcloud compute instance-templates create i27-managed-instance-template-v1 \
       --machine-type=e2-medium \
       --network-interface=network=default,network-tier=PREMIUM \
       --tags=http-server \
       --metadata-from-file=startup-script=startupscript-v1.sh \
       --instance-template-region=us-central1
   ```

---
