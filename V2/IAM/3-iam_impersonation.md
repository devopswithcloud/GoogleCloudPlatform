
---

## **Service Account Impersonation in Google Cloud**

### **What is Service Account Impersonation?**

Service account impersonation in Google Cloud allows a user or service to temporarily assume the identity of a service account and perform actions using that service account’s permissions. This enables delegation of tasks or access to resources without directly giving the user or service broad permissions or exposing sensitive credentials.

By impersonating a service account, a user can execute tasks with the permissions tied to the service account, providing more control over access and ensuring that tasks are performed with the least privilege necessary.

---

## **Scenario Overview**

In this scenario, we are going to:
1. Assign a user, Siva (`siva@gcpbatch22.in`), a **Compute Viewer** role, which will allow him to view Compute Engine resources but **not create virtual machines (VMs)**.
2. Confirm that Siva cannot create VMs.
3. Grant Siva the **Service Account Token Creator** role, allowing him to impersonate a service account.
4. Create a **service account** with the required permissions to create VMs, including **Compute Admin** and **Service Account User** roles.
5. Have Siva impersonate this service account to successfully create a VM.
6. Clean up all the resources we created, including the VMs, IAM role bindings, and the service account.

---

## **Steps to Implement Service Account Impersonation**

### **Step 0: Get the Dynamic Project ID**

Retrieve the active project ID dynamically from your gcloud configuration:

```bash
PROJECT_ID=$(gcloud config get-value project)
```

---

### **Step 1: Assign Siva the Compute Viewer Role**

1. **Grant the Compute Viewer role to Siva**:
   - This will allow Siva to view resources but **not create or modify** them.
   
   ```bash
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="user:siva@gcpbatch22.in" \
     --role="roles/compute.viewer"
   ```

2. **Verify Siva's permissions**:
   - Siva will be able to view Compute Engine resources but **cannot create** virtual machines or modify any resources.

---

### **Step 2: Verify Siva Cannot Create VMs**

1. **Login as Siva**:
   - Log in to the GCP console using the account `siva@gcpbatch22.in`.

2. **Attempt to create a VM via the Console**:
   - Try to create a Compute Engine instance from the GCP console as Siva. It should **fail** due to insufficient permissions.

3. **Attempt to create a VM via gcloud**:
   - From **Siva's Cloud Shell**, try to create a VM using the following command:
   ```bash
   gcloud compute instances create test-vm --zone=us-central1-a
   ```
   - This should also **fail** because Siva only has the **Compute Viewer** role and no permissions to create VMs.

---

### **Step 3: Grant Siva the Service Account Token Creator Role**

1. **Assign the Service Account Token Creator role to Siva**:
   - This role allows Siva to impersonate service accounts in the project.
   
   ```bash
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="user:siva@gcpbatch22.in" \
     --role="roles/iam.serviceAccountTokenCreator"
   ```

2. **Verify Siva's new roles**:
   - Siva should now have the following roles:
     - **Compute Viewer**
     - **Service Account Token Creator**

   You can verify this by running:
   ```bash
   #gcloud projects get-iam-policy $PROJECT_ID --filter="bindings.members:user:siva@gcpbatch22.in"
   gcloud projects get-iam-policy $PROJECT_ID --format=json | jq '.bindings[] | select(.members[] | contains("user:siva@gcpbatch22.in"))'
   ```

---

### **Step 4: Create a Service Account with Elevated Privileges**

1. **Create a new service account** that Siva will impersonate:
   - This service account will have the **Compute Admin** role (which allows full control over VMs) and the **Service Account User** role (which allows other users to impersonate it).

   ```bash
   gcloud iam service-accounts create vm-admin-account \
     --description="Service account for VM administration" \
     --display-name="VM Admin Account"
   ```

2. **Grant the service account the Compute Admin role**:
   - This gives the service account full access to manage VMs.

   ```bash
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:vm-admin-account@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/compute.admin"
   ```

3. **Grant the service account the Service Account User role**:
   - This allows the service account to be used for impersonation by others.
   
   ```bash
   gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member="serviceAccount:vm-admin-account@$PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/iam.serviceAccountUser"
   ```

4. **Grant Siva the Service Account User role on the service account**:
   - This allows Siva to impersonate this service account.

   ```bash
   gcloud iam service-accounts add-iam-policy-binding vm-admin-account@$PROJECT_ID.iam.gserviceaccount.com \
     --member="user:siva@gcpbatch22.in" \
     --role="roles/iam.serviceAccountUser"
   ```

---

### **Step 5: Impersonate the Service Account and Create a VM**

1. **Log back in as Siva**:
   - Go to the **Cloud Shell** in Siva's account (`siva@gcpbatch22.in`).

2. **Impersonate the service account** and attempt to create a VM:
   - Use the service account's email for impersonation and run the following command to create a VM:
   
   ```bash
   gcloud compute instances create vm-impersonated \
     --zone=us-central1-a \
     --impersonate-service-account=vm-admin-account@$PROJECT_ID.iam.gserviceaccount.com --machine-type=e2-medium
   ```

3. **Verify VM Creation**:
   - The VM should be successfully created because Siva is now impersonating the **vm-admin-account** service account, which has the **Compute Admin** role.

4. **Verify the Impersonation**:
   - You can confirm that the impersonation worked by checking the **Cloud Audit Logs** to see that the VM was created by the **service account** rather than Siva directly.

---

### **Step 6: Cleaning Up Resources**

After completing the scenario, you should clean up the resources you created:

1. **Delete the VM**:
   ```bash
   gcloud compute instances delete vm-impersonated --zone=us-central1-a --quiet
   ```

2. **Remove IAM policy bindings from the service account**:
   - **Remove Compute Admin role**:
     ```bash
     gcloud projects remove-iam-policy-binding $PROJECT_ID \
       --member="serviceAccount:vm-admin-account@$PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/compute.admin"
     ```

   - **Remove Service Account User role**:
     ```bash
     gcloud projects remove-iam-policy-binding $PROJECT_ID \
       --member="serviceAccount:vm-admin-account@$PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/iam.serviceAccountUser"
     ```

   - **Remove Siva's Service Account User role on the service account**:
     ```bash
     gcloud iam service-accounts remove-iam-policy-binding vm-admin-account@$PROJECT_ID.iam.gserviceaccount.com \
       --member="user:siva@gcpbatch22.in" \
       --role="roles/iam.serviceAccountUser"
     ```

3. **Delete the service account**:
   ```bash
   gcloud iam service-accounts delete vm-admin-account@$PROJECT_ID.iam.gserviceaccount.com --quiet
   ```

4. **Remove Siva's IAM roles**:

   - **Remove Compute Viewer role**:
     ```bash
     gcloud projects remove-iam-policy-binding $PROJECT_ID \
       --member="user:siva@gcpbatch22.in" \
       --role="roles/compute.viewer"
     ```

   - **Remove Service Account Token Creator role**:
     ```bash
     gcloud projects remove-iam-policy-binding $PROJECT_ID \
       --member="user:siva@gcpbatch22.in" \
       --role="roles/iam.serviceAccountTokenCreator"
     ```

---

### **Summary of Steps:**

1. **Siva** is initially given the **Compute Viewer** role, which prevents him from creating VMs.
2. After logging in as Siva, it is confirmed that he cannot create VMs from the GCP console or Cloud Shell.
3. **Siva** is then granted the **Service Account Token Creator** role, allowing him to impersonate service accounts.
4. A new service account (**vm-admin-account**) is created with **Compute Admin** and **Service Account User** roles.
5. **Siva** impersonates the **vm-admin-account** service account and successfully creates a VM using its elevated permissions.
6. All resources (VM, IAM bindings, and service account) are cleaned up, and `--quiet` is used to skip confirmation prompts during deletions.

---
