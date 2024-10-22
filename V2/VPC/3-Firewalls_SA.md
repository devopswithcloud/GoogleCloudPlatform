
# Setting Up a VM, Configuring a Web Server, Allowing External HTTP Access for `ServiceAccount`, and Cleaning Up

---

### Step 1: Create a Custom VPC and Subnets (Already Done)

If not already created, refer to the previous steps to create a custom VPC and subnets.

---

### Step 2: Create the VM

Create a VM in `subnet-b` using the following command:

```bash
gcloud compute instances create fw-vm-sa     --zone us-central1-a     --subnet=subnet-b     --machine-type=e2-medium
```

---

### Step 3: SSH into the VM

SSH into the created VM using:

```bash
gcloud compute ssh --zone "us-central1-a" "fw-vm-sa"
```

---

### Step 4: Install Apache Web Server and Create a Custom Webpage Inside the VM

Once you’re logged into the VM via SSH, run the following commands to install the Apache web server and set up a custom webpage:

```bash
# Update the package list
sudo apt update -y

# Install Apache2 web server
sudo apt install apache2 -y

# Remove the default index.html file
sudo rm -rf /var/www/html/index.html

# Create a new custom HTML page
echo "Welcome to Firewall SA Example" | sudo tee /var/www/html/index.html
```

---

### Step 5: Test Webpage Accessibility

1. **Access the VM's public IP**:
   - Find the public IP of the `fw-vm-sa` instance using the following command:

     ```bash
     gcloud compute instances describe fw-vm-sa --zone us-central1-a --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
     ```

   - **Or**: Go to the **Google Cloud Console (GCE)**, navigate to **VM instances**, and get the VM’s **External IP** from the console.

2. **Open the public IP in a browser**:
   - Go to `http://<public-ip>` in a browser.

   **Expected Result**: The page will not load. This is because no firewall rule exists to allow external HTTP access on port `80`.

3. **Test with `curl` inside the VM**:
   - While SSH'd into the VM, run:

     ```bash
     curl localhost
     ```

   **Expected Result**: The webpage will display "Welcome to Firewall SA Example" inside the VM.

---

### Step 6: Create a Firewall Rule to Allow HTTP (Port 80) Access

To allow external HTTP access to port `80`, create a firewall rule:

```bash
gcloud compute firewall-rules create allow-ingress-80-sa     --direction=INGRESS     --priority=1000     --network=custom-network     --action=ALLOW     --rules=tcp:80     --source-ranges=0.0.0.0/0     --target-service-accounts=PROJECT_NUMBER-compute@developer.gserviceaccount.com
```

- **Important**: Replace `PROJECT_NUMBER` with your actual Google Cloud project number. To get the project number, run:

  ```bash
  gcloud projects describe PROJECT_ID --format="get(projectNumber)"
  ```

---

### Step 7: Verify External Access to the Webpage

1. **Get the public IP** of the VM:
   - Run:

     ```bash
     gcloud compute instances describe fw-vm-sa --zone us-central1-a --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
     ```

   - **Or**: Go to the **Google Cloud Console (GCE)**, navigate to **VM instances**, and get the VM’s **External IP** from the console.

2. **Access the webpage** from your browser:

   Go to `http://<public-ip>` in your browser.

   **Expected Result**: The webpage should now be accessible, displaying "Welcome to Firewall SA Example."

---

### Step 8: Clean Up – Delete the VM and Firewall Rule

#### 1. **Delete the VM**

Run the following command to delete the VM `fw-vm-sa`:

```bash
gcloud compute instances delete fw-vm-sa --zone us-central1-a --quiet
```

Alternatively, you can also delete the VM from the **Google Cloud Console (GCE)**:
- Go to **VM instances** under **Compute Engine**.
- Select the VM `fw-vm-sa`.
- Click on **Delete**.

#### 2. **Delete the Firewall Rule**

Run the following command to delete the firewall rule that allows HTTP access (port 80):

```bash
gcloud compute firewall-rules delete allow-ingress-80-sa --quiet
```

Alternatively, you can delete the firewall rule from the **Google Cloud Console (GCE)**:
- Go to **Firewall rules** under **VPC network**.
- Find the rule `allow-ingress-80-sa`.
- Click on **Delete**.

---

This complete flow sets up a VM, installs a web server, restricts external HTTP access initially, adds a firewall rule to allow HTTP access, and cleans up resources by deleting the VM and firewall rule. The custom VPC and SSH firewall rule are retained for future use.
