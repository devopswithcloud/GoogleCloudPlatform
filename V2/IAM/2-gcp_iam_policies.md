
---

### **Introduction: What You Will Learn**

In this guide, we will cover how to manage **IAM policies** in Google Cloud Platform (GCP) by working with users and service accounts to grant and revoke permissions on resources. Specifically, you will learn how to:

1. Investigate and manage access to **Google Cloud Storage (GCS)** for a user.
2. Create and attach a **Service Account** to a **VM** to interact with GCP services.
3. Add and remove **IAM policy bindings** to grant appropriate permissions.
4. Perform cleanup by removing **IAM bindings**, **service accounts**, **VMs**, and **GCS buckets** to avoid unnecessary costs.

---

### **Overview of IAM Policies in GCP**

In Google Cloud Platform (GCP), **policies** are a set of rules that define who can access which resources and what actions they can perform on those resources. Policies are critical for managing and securing access to cloud resources.

#### Key Components of a GCP Policy:
1. **Members**: The identities (users, groups, service accounts, etc.) that request access to resources.
   - Examples: `user:example@gmail.com`, `serviceAccount:my-sa@my-project.iam.gserviceaccount.com`, `group:devops@example.com`

2. **Roles**: Define a set of permissions that determine what actions a member can perform on a resource.
   - Examples: `roles/viewer` (read-only access), `roles/editor` (read/write access), `roles/owner` (full control)

3. **Permissions**: Each role consists of a set of permissions, which are fine-grained actions that can be performed on specific resources (like viewing, creating, or deleting resources).

4. **Resources**: The GCP entities to which the policies apply, such as projects, compute instances, storage buckets, etc.

5. **Bindings**: A policy is made up of one or more bindings, each binding connects a **member** to a **role** for a specific **resource**.

---

### **Scenario: Managing Access to GCS for a User**


```bash
#### Step 0: Get the Dynamic Project ID
#Retrieve the active project ID dynamically from your gcloud configuration:
PROJECT_ID=$(gcloud config get-value project)

#### Step 1: User Tries to Access GCS without Appropriate Permissions

- **User**: `siva@gcpbatch22.in`
- **Project**: A GCP project with the ID `your-project-id`
- **Resource**: A Google Cloud Storage (GCS) bucket in the project.
- **Pre-access**: Make sure `siva` has Compute Admin Access only and no other access.

**Siva**, who is part of the GCP project `your-project-id`, logs into the GCP Console using his account (`siva@gcpbatch22.in`) and tries to access a GCS bucket in the project. However, Siva cannot access the bucket because he hasn’t been assigned any roles that permit GCS access.

#### Step 2: No Access to GCS

Siva is unable to access the GCS bucket because, by default, he only has the roles and permissions explicitly granted to him. In this case, Siva needs a specific role, such as `roles/storage.objectViewer` or `roles/storage.admin`, to interact with GCS.

#### Step 3: Investigating the Issue

To understand why Siva cannot access the GCS bucket, we need to check the current IAM policies associated with the project. This will allow us to see which roles are assigned to Siva.

##### Command to List IAM Policies:

```bash
gcloud projects get-iam-policy $PROJECT_ID
```

- **`$PROJECT_ID`**: The project ID where the GCS bucket exists. You can retrieve it dynamically with:

  ```bash
  PROJECT_ID=$(gcloud config get-value project)
  ```

By listing the current IAM policies, we can verify that Siva does not have any roles that allow him to interact with the GCS bucket, such as `roles/storage.objectViewer`.

---

### **View IAM Policy in Different Formats**

#### View IAM Policy in JSON Format:
```bash
gcloud projects get-iam-policy $PROJECT_ID --format=json
```

#### View IAM Policy in YAML Format:
```bash
gcloud projects get-iam-policy $PROJECT_ID --format=yaml
```

---

### **Granting Full Access to Siva with `roles/storage.admin`**

#### Step 4: Granting Full Access to Siva

To allow **Siva** (`siva@gcpbatch22.in`) full access to manage the Google Cloud Storage bucket, we will grant him the **Storage Admin** role, which provides full control over the bucket and its contents.

##### Command to Add GCS Admin Access for Siva:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:siva@gcpbatch22.in" \
    --role="roles/storage.admin"
```

- **`--member="user:siva@gcpbatch22.in"`**: Specifies the user who needs the role.
- **`--role="roles/storage.admin"`**: Grants full control over Cloud Storage, including the ability to modify objects and permissions.

#### Step 5: Verify the Role Assignment

Once you've granted the `storage.admin` role, verify that the policy has been successfully updated by checking the project's IAM policies.

##### Command to Verify the Policy:

```bash
gcloud projects get-iam-policy $PROJECT_ID --format=yaml
```

#### Step 6: Siva Tries to Access GCS Again

With the `roles/storage.admin` role assigned, Siva now has full control over the GCS bucket. He can:
- Create new objects in the bucket.
- Delete or modify existing objects.
- Change permissions for the bucket or its contents.

Siva should log back into the GCP Console and verify that he can perform all of these actions in the GCS bucket.



---

### **Scenario: Working with Service Accounts**

#### Step 1: Create a Service Account Using gcloud CLI

We’ll start by creating a new service account for interacting with GCP resources.

##### Command to Create a Service Account:

```bash
gcloud iam service-accounts create my-service-account \
    --description="Service account for GCS operations" \
    --display-name="GCS Service Account"
```

---

### Step 2: Attach the Service Account to a VM (Debian 11)

Now, we’ll create a VM with **Debian 11** and attach the service account to it.

##### Command to Create a VM with the Service Account:

```bash
gcloud compute instances create vm-with-svc-account \
    --service-account=my-service-account@$PROJECT_ID.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-project=debian-cloud \
    --image-family=debian-11
```

---

### Step 3: SSH into the VM and Verify Service Account Configuration

Once the VM is created, we’ll SSH into the VM to ensure we’re logged in with the service account.

##### Command to SSH into the VM:

```bash
gcloud compute ssh vm-with-svc-account --zone=us-central1-a
```

##### Command to Check the Active Configuration (to verify service account):

```bash
gcloud auth list
```

This command will list all authenticated accounts. You should see the service account (`my-service-account@$PROJECT_ID.iam.gserviceaccount.com`) listed as the active account.

---

### Step 4: Try Creating a GCS Bucket from the VM (Fail Expected)

After verifying the service account, try to create a Google Cloud Storage bucket to confirm the current permissions.

##### Command to Attempt Creating a GCS Bucket:

```bash
gsutil mb gs://my-test-bucket-$RANDOM
```

At this point, the command is expected to **fail** because the service account doesn’t have the necessary permissions yet.

---

### Step 5: Add IAM Policy Binding for the Service Account

We need to grant the `Storage Admin` role to the service account to allow it to manage GCS resources.

##### Command to Add IAM Policy Binding:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:my-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"
```

This grants the service account full control over GCS.

---

### Step 6: Verify Permissions and Try Again

Once the permissions are granted, SSH back into the VM and try to create a GCS bucket again.

##### Command to SSH Back into the VM:

```bash
gcloud compute ssh vm-with-svc-account --zone=us-central1-a
```

##### Command to Create a GCS Bucket:

```bash
gsutil mb gs://my-test-bucket-$RANDOM
```

This time, the

 bucket creation should succeed, confirming that the service account has the required permissions.

---

---

### **Assigning Storage Admin Role to User and Service Account**

You can assign the **Storage Admin** role to both a user and a service account in a single policy using **gcloud** and **YAML**.

#### gcloud Command:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:siva@gcpbatch22.in" \
    --member="serviceAccount:my-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"
```

#### YAML Format:

```yaml
bindings:
- role: roles/storage.admin
  members:
  - user:siva@gcpbatch22.in
  - serviceAccount:my-service-account@$PROJECT_ID.iam.gserviceaccount.com
```

You can apply the YAML policy using:

```bash
gcloud projects set-iam-policy $PROJECT_ID iam-policy.yaml
```

### **Cleaning Steps: Remove IAM Bindings, Service Account, VM, and GCS Bucket**

To avoid unnecessary costs and clean up resources, use the following steps:

#### Step 1: Remove IAM Policy Binding for the Service Account

To clean up and remove the access granted to the service account:

```bash
gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:my-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin" --quiet
```

#### Step 2: Delete the Service Account

Once permissions have been removed, delete the service account:

```bash
gcloud iam service-accounts delete my-service-account@$PROJECT_ID.iam.gserviceaccount.com --quiet
```

#### Step 3: Delete the VM

To delete the VM without prompts:

```bash
gcloud compute instances delete vm-with-svc-account --zone=us-central1-a --quiet
```

#### Step 4: Delete the GCS Bucket

Finally, delete the GCS bucket (if created):

```bash
gsutil rm -r gs://my-test-bucket-$RANDOM
```

---

This guide provides a complete, step-by-step walkthrough for managing IAM roles, service accounts, and GCP resources, including automated cleanup.
