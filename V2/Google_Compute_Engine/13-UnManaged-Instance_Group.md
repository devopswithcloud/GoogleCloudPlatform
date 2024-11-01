### **Guide for Setting up an Unmanaged Instance Group with Blue and Green VMs**

#### **In this guide, you will:**

1. **Create Startup Scripts**:
   - Set up unique `Green` and `Blue` startup scripts to configure the web servers and provide color-specific pages for each VM.
  
2. **Create Blue and Green VMs**:
   - Deploy `green-vm` and `blue-vm` in `us-central1-a` using their respective startup scripts.

3. **Create Firewall Rule**:
   - Open port 80 for HTTP access from all sources, specifically for the unmanaged instance group.

4. **Create Unmanaged Instance Group**:
   - Set up an unmanaged instance group, `i27-unmig`, in `us-central1-a`.
   - Add `green-vm` and `blue-vm` to the group and map port 80 to `i27-web-port`.

5. **Include Health Checks Information**:
   - Note about configuring health checks separately for monitoring instance availability.

6. **Commands for Deletion**:
   - Clean up all resources created, including VMs, firewall rule, and instance group.

---

### **Complete Setup Steps for the Unmanaged Instance Group**

---

### **1. Create Startup Scripts for Blue and Green VMs**

Save these scripts as `script-green.sh` and `script-blue.sh`.

- **`script-green.sh`** (Green VM Startup Script):
  ```bash
  #!/bin/bash
  # Install necessary packages
  sudo apt install -y telnet
  sudo apt install -y nginx

  # Enable and start Nginx
  sudo systemctl enable nginx
  sudo systemctl start nginx

  # Set permissions
  sudo chmod -R 755 /var/www/html

  # Get hostname and IP address
  HOSTNAME=$(hostname)
  IP_ADDRESS=$(hostname -I | awk '{print $1}')

  # Create the HTML file with dynamic hostname and IP address
  sudo echo "<!DOCTYPE html>
  <html lang=\"en\">
  <head>
      <meta charset=\"UTF-8\">
      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
      <title>i27Academy GCP UnManaged Instance Group Demo</title>
      <style>
          body {
              font-family: Arial, sans-serif;
              background-color: #f0f0f0;
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              margin: 0;
          }
          .container {
              text-align: center;
              background-color: #ffffff;
              padding: 20px;
              border-radius: 8px;
              box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
          }
          .title {
              font-size: 24px;
              font-weight: bold;
              margin-bottom: 20px;
          }
          .message {
              font-size: 18px;
              font-weight: bold;
              color: #008000; /* Green color for Green-VM */
              margin-top: 10px;
          }
          .details {
              font-size: 16px;
              color: #555555;
              margin-top: 5px;
              font-style: italic;
          }
      </style>
  </head>
  <body>
      <div class="container">
          <div class="title">i27Academy GCP UnManaged Instance Group Example</div>
          <div class="message">Request Coming from ${HOSTNAME}</div>
          <div class="details">Server IP Address: ${IP_ADDRESS}</div>
      </div>
  </body>
  </html>
  " | sudo tee /var/www/html/index.html > /dev/null
  ```

- **`script-blue.sh`** (Blue VM Startup Script):
  ```bash
  #!/bin/bash
  # Install necessary packages
  sudo apt install -y telnet
  sudo apt install -y nginx

  # Enable and start Nginx
  sudo systemctl enable nginx
  sudo systemctl start nginx

  # Set permissions
  sudo chmod -R 755 /var/www/html

  # Get hostname and IP address
  HOSTNAME=$(hostname)
  IP_ADDRESS=$(hostname -I | awk '{print $1}')

  # Create the HTML file with dynamic hostname and IP address, with blue color for Blue-VM
  sudo echo "<!DOCTYPE html>
  <html lang=\"en\">
  <head>
      <meta charset=\"UTF-8\">
      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
      <title>i27Academy GCP UnManaged Instance Group Demo</title>
      <style>
          body {
              font-family: Arial, sans-serif;
              background-color: #f0f0f0;
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              margin: 0;
          }
          .container {
              text-align: center;
              background-color: #ffffff;
              padding: 20px;
              border-radius: 8px;
              box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
          }
          .title {
              font-size: 24px;
              font-weight: bold;
              margin-bottom: 20px;
          }
          .message {
              font-size: 18px;
              font-weight: bold;
              color: #0000ff; /* Blue color for Blue-VM */
              margin-top: 10px;
          }
          .details {
              font-size: 16px;
              color: #555555;
              margin-top: 5px;
              font-style: italic;
          }
      </style>
  </head>
  <body>
      <div class="container">
          <div class="title">i27Academy GCP UnManaged Instance Group Example</div>
          <div class="message">Request Coming from ${HOSTNAME}</div>
          <div class="details">Server IP Address: ${IP_ADDRESS}</div>
      </div>
  </body>
  </html>
  " | sudo tee /var/www/html/index.html > /dev/null
  ```

---

### **2. Create Blue and Green VMs Using the Startup Scripts**

- **Green VM**:
  ```bash
  gcloud compute instances create green-vm \
      --zone=us-central1-a \
      --machine-type=e2-medium \
      --metadata-from-file=startup-script=script-green.sh
  ```

- **Blue VM**:
  ```bash
  gcloud compute instances create blue-vm \
      --zone=us-central1-a \
      --machine-type=e2-medium \
      --metadata-from-file=startup-script=script-blue.sh
  ```

---

### **3. Create Firewall Rule to Allow HTTP Traffic on Port 80**

- **Firewall Rule for HTTP Access**:
  ```bash
  gcloud compute firewall-rules create allow-http-unmanaged \
      --direction=INGRESS \
      --priority=1000 \
      --network=default \
      --action=ALLOW \
      --rules=tcp:80 \
      --source-ranges=0.0.0.0/0 \
      --description="Allow incoming HTTP traffic on port 80 from all sources for unmanaged instance group"
  ```

---

### **4. Create Unmanaged Instance Group with Blue and Green VMs**

1. **Create the Unmanaged Instance Group**:
   ```bash
   gcloud compute instance-groups unmanaged create i27-unmig \
       --project=criticalproject \
       --description="i27 Un Managed Group Example" \
       --zone=us-central1-a
   ```

2. **Set the Named Port for the Group**:
   ```bash
   gcloud compute instance-groups unmanaged set-named-ports i27-unmig \
       --project=criticalproject \
       --zone=us-central1-a \
       --named-ports=i27-web-port:80
   ```

3. **Add Instances to the Unmanaged Group**:
   ```bash
   gcloud compute instance-groups unmanaged add-instances i27-unmig \
       --project=criticalproject \
       --zone=us-central1-a \
       --instances=blue-vm,green-vm
   ```

---

### **Note on Health Checks**

For unmanaged instance groups, **health checks** aren’t automatically created but can be configured separately to monitor the health and availability of instances within the group. This helps in determining if an instance is healthy and capable of serving traffic.

---

### **Commands to Delete Resources Created**

1. **Delete the Unmanaged Instance Group**:
   ```bash
   gcloud compute instance-groups unmanaged delete i27-unmig \
       --project=criticalproject \
       --zone=us-central1-a \
       --quiet
   ```

2. **Remove Instances from the Unmanaged Instance Group**:
   ```bash
   gcloud compute instance-groups unmanaged remove-instances i27-unmig \
       --project=criticalproject \
       --zone=us-central1-a \
       --instances=blue-vm,green-vm \
       --quiet
   ```

3. **Delete the Blue and Green VMs**:
   - **Green VM**:
     ```bash
     gcloud compute instances delete green-vm \
         --zone=us-central1-a \
         --quiet
     ```
   - **Blue VM**:
    ```bash
    gcloud compute instances delete blue-vm \
        --zone=us-central1-a \
        --quiet
    ```

4. **Delete the Firewall Rule**:
   ```bash
   gcloud compute firewall-rules delete allow-http-unmanaged \
       --project=criticalproject \
       --quiet
   ```

---

### **Summary**

- **Instance Group Name**: `i27-unmig`
- **Description**: `i27 Un Managed Group Example`
- **Zone**: `us-central1-a`
- **Network**: `default`
- **Named Port**: `i27-web-port` mapped to port `80`
- **VM Instances**: `green-vm`, `blue-vm`
