
# Guide: Overriding Project-Level Metadata with a VM-Level Startup Script

This guide demonstrates how to override a project-level startup script by specifying a unique VM-level script during VM creation.

---

### Step 1: Set the Project-Level Startup Script

If a project-level startup script is not already set, you can follow these instructions to add one:

1. **Go to the Google Cloud Console**.
2. Navigate to **Compute Engine** > **Settings**.
3. Select the **Metadata** tab.
4. Click **Edit** to add new metadata.
5. Click **Add Item**.
   - **Key**: Enter `startup-script`.
   - **Value**: Enter any default script, as this guide will override it at the VM level.
6. Click **Save**.

This step ensures a project-level startup script is in place, which the VM-level script will override.

---

### Step 2: Create a VM with a VM-Level Startup Script

1. Go to **Compute Engine** > **VM Instances**.
2. Click **Create Instance**.
3. **Name**: Enter a name for the VM, like `override-project-vm`.
4. **Zone**: Choose **us-central1-a** (or your preferred zone).
5. **Machine Type**: Select **e2-micro** (or leave the default).
6. **Firewall**: Optionally, check **Allow HTTP traffic** to enable access to the web server.
7. Scroll down to **Advanced Options** and expand it.
8. **Under Automation**:
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
        <h1>i27academy Google Cloud Platform - Overriding Project Metadata</h1>
        <p><strong class='hostname'>Server Hostname:</strong> ${HOSTNAME}</p>
        <p><strong class='ip-address'>Server IP Address:</strong> $(hostname -I)</p>
        <p class='version'>Version-1</p>
    </body>
    </html>" | sudo tee /var/www/html/index.html
    ```

9. Click **Create** to launch the VM.

The VM-specific startup script will run, overriding the project-level script and creating a custom HTML page with **"Overriding Project Metadata"** in the heading.

---

### Step 3: Access the Custom Webpage

1. Once the VM is created and running, go back to the **VM instances** page.
2. Copy the **External IP** of the VM.
3. Open a web browser and navigate to `http://[YOUR_VM_EXTERNAL_IP]`.

You should see a custom HTML page displaying **"i27academy Google Cloud Platform - Overriding Project Metadata"**, along with the server’s hostname, IP address, and version.

---


