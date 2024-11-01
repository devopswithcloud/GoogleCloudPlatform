
# Google Compute Engine (GCE) - Creating, Installing Web Server, and Managing VM

This guide provides step-by-step instructions to create a VM, install a web server, and manage the VM lifecycle on Google Cloud Platform.

---

## Step 1: Create a VM Instance with HTTP Access

Use the following command to create a VM instance named `first-vm-cli` in the **us-central1-a** zone with an **e2-medium** machine type. This command also assigns the **http-server** tag to allow HTTP traffic.

```bash
gcloud compute instances create first-vm-cli \
    --zone us-central1-a \
    --machine-type=e2-medium \
    --tags=http-server
```

This command initializes a VM instance in the specified zone with the specified machine configuration and assigns a tag to allow HTTP traffic.

---

## Step 2: Set Up Firewall Rules (if not already in place)

Ensure that a firewall rule exists to allow HTTP traffic to VMs with the **http-server** tag. If it’s not already set, you can create the rule as follows:

```bash
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --target-tags=http-server
```

This firewall rule allows incoming traffic on port 80 for instances tagged with **http-server**.

---

## Step 3: SSH into the VM

SSH into the created VM using:

```bash
gcloud compute ssh first-vm-cli --zone us-central1-a
```

This opens an SSH session to the VM, allowing you to run commands directly on it.

---

## Step 4: Create and Execute a Script to Install Nginx and Set Up a Custom Webpage

1. **Create a script file**: Inside the VM, create a file named `install-webserver.sh`:

    ```bash
    vim install-webserver.sh
    ```

2. **Press `i`** to enter **Insert mode**, then add the following content to the script file:

    ```bash
    #!/bin/bash
    # Update package list and install Nginx
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl enable nginx

    # Set permissions for web directory
    sudo chmod -R 755 /var/www/html

    # Define and create a custom HTML page with styled content
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
        <p><strong class="hostname">Server Hostname:</strong> ${HOSTNAME}</p>
        <p><strong class="ip-address">Server IP Address:</strong> $(hostname -I)</p>
        <p class="version">Version-1</p>
    </body>
    </html>" | sudo tee /var/www/html/index.html
    ```

3. **Save and exit** the file:
    - Press `Esc` to leave Insert mode.
    - Type `:wq` and press `Enter` to save and quit.

4. **Make the script executable**:

    ```bash
    chmod +x install-webserver.sh
    ```

5. **Execute the script** to install Nginx and set up the custom webpage:

    ```bash
    ./install-webserver.sh
    ```

---

## Step 5: Verify the Web Server

Once the setup is complete:
1. Open a browser and navigate to `http://[YOUR_VM_EXTERNAL_IP]`.
2. You should see the custom webpage displaying the hostname, IP address, and styled content.

---

# VM Management Tasks

The following commands help you manage your VM with **stop**, **start**, **resume**, **suspend**, **reset**, and **delete** tasks:

---

### Stopping the VM

Stops the VM but retains disk data and configuration.

```bash
gcloud compute instances stop first-vm-cli --zone us-central1-a
```

---

### Starting the VM

Powers on the VM, starting compute costs.

```bash
gcloud compute instances start first-vm-cli --zone us-central1-a
```

---

### Suspending the VM

Pauses the VM and saves its state to disk.

```bash
gcloud compute instances suspend first-vm-cli --zone us-central1-a
```

---

### Resuming a Suspended VM

Restores the VM to its previous state.

```bash
gcloud compute instances resume first-vm-cli --zone us-central1-a
```

---

### Resetting the VM

Performs a hard reboot of the VM.

```bash
gcloud compute instances reset first-vm-cli --zone us-central1-a
```

---

### Deleting the VM

Permanently removes the VM and attached resources with automatic deletion.

```bash
gcloud compute instances delete first-vm-cli --zone us-central1-a
```

--- 

This completes the guide for **creating, installing, and managing** a VM with essential commands for lifecycle control.

