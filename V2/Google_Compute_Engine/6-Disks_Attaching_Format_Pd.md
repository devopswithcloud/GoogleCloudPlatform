
---

# **Google Cloud VM and Disk Configuration Guide**

### **Overview**

In this guide, we’ll walk through the following tasks:

1. **Creating a VM with a Startup Script**: Set up a virtual machine (VM) in Google Cloud, configure it to serve a custom web page, and set a startup script.
2. **Creating and Attaching a Persistent Disk**: Provision a persistent disk, attach it to the VM, and set it up for data storage.
3. **Formatting and Mounting the Disk**: Format the newly attached disk and mount it to make it accessible on the VM.
4. **Configuring Auto-Mount on Reboot**: Modify the VM’s configuration so that the disk automatically mounts every time the VM restarts.
5. **Verifying Disk Persistence**: Restart the VM to verify that the disk remains accessible and properly mounted after reboot.
6. **Cleaning Up Resources**: Delete the VM and the disk to avoid any unnecessary costs.

---

### **Step 1: Create the VM with a Startup Script**

1. **Create the Startup Script**: Save the following content in a file called `startup-script.sh`. This script installs necessary packages and sets up a custom HTML page.

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
        <h1>i27academy Google Cloud Platform - Disk Example</h1>
        <p><strong class='hostname'>Server Hostname:</strong> ${HOSTNAME}</p>
        <p><strong class='ip-address'>Server IP Address:</strong> $(hostname -I)</p>
        <p class='version'>Disk Setup Example</p>
    </body>
    </html>" | sudo tee /var/www/html/index.html
    ```

    - This HTML includes **"Disk Example"** as the title and **"Disk Setup Example"** as the version.

2. **Create the VM with gcloud**: Use the following `gcloud` command to create the VM and pass the startup script.

    ```bash
    gcloud compute instances create disk-example-vm \
        --zone=us-central1-a \
        --machine-type=e2-micro \
        --tags=http-server \
        --metadata-from-file startup-script=startup-script.sh
    ```

    - This command creates a VM named `disk-example-vm` in the `us-central1-a` zone, with `startup-script.sh` applied as a startup script.

---

### **Step 2: Create a Disk in Google Cloud Console**

1. **Navigate to Compute Engine Disks**: In the Google Cloud Console, go to **Compute Engine** > **Disks**.
2. **Create Disk**:
   - Click **Create Disk**.
   - **Name**: Enter `i27disk1`.
   - **Location**: Set to **Zonal** and select **us-central1-a** as the zone.
   - **Source Type**: Choose **Blank Disk**.
   - **Disk Type**: Select **Balanced Persistent Disk**.
   - **Size**: Set the size to **20 GB**.
   - **Encryption**: Leave as default.
3. **Create**: Click **Create** to provision the disk.

4. **Optional gcloud Command**:
    ```bash
    gcloud compute disks create i27disk1 \
        --size=20GB \
        --type=pd-balanced \
        --zone=us-central1-a
    ```

---

### **Step 3: Attach the Disk to the VM**

1. **Go to the VM**: In the Google Cloud Console, navigate to **Compute Engine** > **VM instances**.
2. **Edit VM**:
   - Find `disk-example-vm` and click on it.
   - Click **Edit** at the top of the page.
   - Scroll to the **Additional Disks** section and click **Attach Existing Disk**.
   - **Select Disk**: Choose `i27disk1` from the dropdown menu.
   - **Mode**: Set to **Read/Write**.
   - **Deletion Rule**: Select **Keep Disk** to retain the disk if the VM is deleted.
3. **Save**: Click **Save** to apply changes.

   - **Note**: Ensure that both the VM (`disk-example-vm`) and disk (`i27disk1`) are in the same zone (`us-central1-a`).

---

### **Step 4: Mount the Disk on the VM**

1. **SSH into the VM**:
   - Go to **Compute Engine** > **VM instances**.
   - Click **SSH** next to the `disk-example-vm` instance.

2. **Identify the Disk**:
   - List all attached disks to verify the presence of `i27disk1`:
     ```bash
     lsblk
     ```
   - Alternatively, use the following command to see disks by their IDs:
     ```bash
     ls -l /dev/disk/by-id/google-*
     ```
   - This command lists all disks attached to the VM, identified by their Google Cloud-assigned IDs, making it easier to distinguish newly attached disks.

3. **Format the Disk**:
   - Format the disk with `ext4`:
     ```bash
     sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
     ```

4. **Create a Mount Directory**:
   - Create a directory for mounting, e.g., `/mnt/disks/i27disk1`:
     ```bash
     sudo mkdir -p /mnt/disks/i27disk1
     ```

5. **Mount the Disk**:
   - Mount the disk to the newly created directory:
     ```bash
     sudo mount -o discard,defaults /dev/sdb /mnt/disks/i27disk1
     ```

6. **Set Permissions (Optional)**:
   - Change permissions if needed:
     ```bash
     sudo chmod -R 777 /mnt/disks/i27disk1
     ```

7. **Configure Auto-Mount on Reboot**:

   - **Why We Need to Mount and Configure the Disk**: When a disk is attached to a VM, it is recognized by the operating system but isn’t automatically ready for use. The steps to format and mount the disk are necessary to make it accessible for storing data. Without these steps:
     - The disk remains unformatted and inaccessible.
     - The VM doesn’t know where to access the data on this disk, making it unusable for applications and services.
   - **Configuring `/etc/fstab`** allows the disk to **auto-mount** on every reboot, ensuring continuous access without needing to manually remount after each reboot.

   1. **Good Practice: Backup the `fstab` File**: The `/etc/fstab` file is crucial as it controls which filesystems are mounted at boot. Before editing, it’s a good practice to back up the file to prevent configuration issues in case of an error.

      ```bash
      sudo cp /etc/fstab /etc/fstab.backup
      ```

   2. **Get the Disk UUID**:
      - Retrieve the disk’s UUID, which uniquely identifies it in the system:
        ```bash
        sudo blkid /dev/sdb
        ```

   3. **Edit the `/etc/fstab` File**:
      - Open the file with a text editor:
        ```bash
        sudo nano /etc/fstab
        ```
      - Add a line to mount the disk using its UUID. Replace `<your-disk-UUID>` with the actual UUID:
        ```
        UUID=<your-disk-UUID> /mnt/disks/i27disk1 ext4 discard,defaults 0 2
        ```

   4. **Save and Test**:
      - Save the file and verify the setup:
        ```bash
        sudo mount -a
        ```

---

### **Step 5: Verify Disk Availability After Restart**

1. **Stop the VM**:
   - Use the following `gcloud` command to stop the VM:
     ```bash
     gcloud compute instances stop disk-example-vm --zone=us-central1-a
     ```

2. **Start the VM**:
   - Start the VM again using:
     ```bash
     gcloud compute instances start disk-example-vm --zone=us-central1-a
     ```

3. **Connect to the VM**:
   - SSH into the VM to verify the disk mount

:
     ```bash
     gcloud compute ssh disk-example-vm --zone=us-central1-a
     ```

4. **Check Mounted Disks**:
   - Once connected, use the following command to check if the disk is available:
     ```bash
     df -h
     ```
   - The output should list the `/mnt/disks/i27disk1` mount, indicating that the disk is automatically available after the VM restart.

---

### **Step 6: Cleanup - Delete All Resources**

1. **Delete the VM**:
   - Use this command to delete the VM:
     ```bash
     gcloud compute instances delete disk-example-vm --zone=us-central1-a --quiet
     ```

2. **Delete the Disk**:
   - After deleting the VM, delete the `i27disk1` disk:
     ```bash
     gcloud compute disks delete i27disk1 --zone=us-central1-a --quiet
     ```

3. **Delete the Startup Script File**:
   - If the `startup-script.sh` file was created locally, delete it:
     ```bash
     rm startup-script.sh
     ```

---

