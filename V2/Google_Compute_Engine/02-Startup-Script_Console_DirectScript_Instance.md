
# Guide: Passing a Linux Startup Script Directly in Google Cloud

This guide provides step-by-step instructions for creating a VM with a Linux startup script that installs software, configures services, and creates a custom HTML page.

---

### Step 1: Navigate to VM Instances in Google Cloud Console

#### Console Instructions
1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. In the **Navigation menu**, select **Compute Engine** > **VM instances**.
3. Click **Create Instance** at the top.

#### gcloud Command
Alternatively, you can start creating a VM directly using `gcloud` commands:

```bash
gcloud compute instances create i27academy-vm
```

---

### Step 2: Configure VM Settings

#### Console Instructions
1. **Name**: Enter `i27academy-vm` as the instance name.
2. **Region and Zone**: Select **us-central1-a** or your preferred zone.
3. **Machine Configuration**: Choose **e2-medium** as the machine type.

#### gcloud Command
To configure the name, region, and machine type, use:

```bash
gcloud compute instances create i27academy-vm     --zone us-central1-a     --machine-type=e2-medium
```

---

### Step 3: Configure Firewall Rules

#### Console Instructions
1. Scroll down to the **Firewall** section.
2. Check **Allow HTTP traffic** to enable access to the web server.

#### gcloud Command
To create a firewall rule allowing HTTP traffic (if not already configured):

```bash
gcloud compute firewall-rules create allow-http     --allow tcp:80     --target-tags=http-server
```

---

### Step 4: Configure Advanced Options for the Startup Script

#### Console Instructions

1. Scroll down to **Advanced Options** and expand the section.

2. **Under Management**:
   - **Description**: Enter a description for the instance, such as “i27academy VM for demo purposes.”
   - **Enable deletion protection**: Check this box to prevent accidental deletion of the instance.
   - **Reservation**: Leave as **Default** (we’ll discuss this option later).

3. **Under Automation**:
   - **Startup script**: Paste the following script in the provided field:

    ```bash
    #!/bin/bash
    sudo apt install -y telnet
    sudo apt install -y nginx
    sudo systemctl enable nginx
    sudo chmod -R 755 /var/www/html
    HOSTNAME=$(hostname)
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
            h1 { color: #ffab00; font-size: 2.5em; margin-bottom: 20px; }
            p { font-size: 1.2em; margin: 10px 0; }
            .hostname { color: #ffccbc; }
            .ip-address { color: #80deea; }
            .version { color: #ff5722; font-weight: bold; font-size: 1.5em; margin-top: 30px; }
            strong { color: #e0f2f1; }
        </style>
    </head>
    <body>
        <h1>i27academy Google Cloud Platform</h1>
        <p><strong class='hostname'>Server Hostname:</strong> ${HOSTNAME}</p>
        <p><strong class='ip-address'>Server IP Address:</strong> $(hostname -I)</p>
        <p class='version'>Version-1</p>
    </body>
    </html>" | sudo tee /var/www/html/index.html
    ```

4. **Metadata and Data Encryption**: Leave both sections with their **Default** settings.


### Step 5: Create the Instance

#### Console Instructions
1. Review the settings to ensure they’re correct.
2. Click **Create** to launch the VM.

---

### Step 6: Access the Custom Webpage

1. Once the VM is created and running, return to the **VM instances** page.
2. Copy the **External IP** of `i27academy-vm`.
3. Open a web browser and navigate to `http://[YOUR_VM_EXTERNAL_IP]`.

You should see a custom HTML page displaying **i27academy Google Cloud Platform**, along with the server’s hostname, IP address, and version.

---

### Step 7: View VM Logs from the Browser

#### Console Instructions
1. In the **VM instances** page, locate your instance (`i27academy-vm`).
2. Click on **More actions** (the three vertical dots) next to the VM name.
3. Select **View logs**.

This will take you to the **Logs Explorer** where you can see detailed logs, including entries related to the startup script.

---

### Step 8: Disable Deletion Protection and Delete the VM

#### Console Instructions

1. In **Compute Engine** > **VM instances**, locate `i27academy-vm`.
2. Click **More actions** (three dots) and select **Edit**.
3. In the **Management** section, **uncheck** **Enable deletion protection** and click **Save**.
4. Return to **More actions**, select **Delete**, and confirm.

#### gcloud Command
To disable deletion protection and delete the VM:

1. First, disable deletion protection:

    ```bash
    gcloud compute instances update i27academy-vm --no-deletion-protection --zone us-central1-a
    ```

2. Then, delete the VM:

    ```bash
    gcloud compute instances delete i27academy-vm --zone us-central1-a
    ```

---

This guide provides detailed steps for creating, managing, and deleting a VM with a Linux startup script on Google Cloud using **Console** and **gcloud commands**. Let me know if you need further customization!
