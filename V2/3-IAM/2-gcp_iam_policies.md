
---

### **Introduction: What You Will Learn**

In this guide, we will cover how to manage **IAM policies** in Google Cloud Platform (GCP) by working with users to grant and revoke permissions on resources. Specifically, you will learn how to:

1. Investigate and manage access to **Google Cloud Storage (GCS)** for a user.
2. Add and remove **IAM policy bindings** to grant appropriate permissions.

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

- **User**: `akash@gcpbatch22.in`
- **Project**: A GCP project with the ID `your-project-id`
- **Resource**: A Google Cloud Storage (GCS) bucket in the project.
- **Pre-access**: Make sure `akash` has Compute Admin Access only and no other access.

**akash**, who is part of the GCP project `your-project-id`, logs into the GCP Console using his account (`akash@gcpbatch22.in`) and tries to access a GCS bucket in the project. However, akash cannot access the bucket because he hasn’t been assigned any roles that permit GCS access.

#### Step 2: No Access to GCS

akash is unable to access the GCS bucket because, by default, he only has the roles and permissions explicitly granted to him. In this case, akash needs a specific role, such as `roles/storage.objectViewer` or `roles/storage.admin`, to interact with GCS.

#### Step 3: Investigating the Issue

To understand why akash cannot access the GCS bucket, we need to check the current IAM policies associated with the project. This will allow us to see which roles are assigned to akash.

##### Command to List IAM Policies:

```bash
gcloud projects get-iam-policy $PROJECT_ID
```

- **`$PROJECT_ID`**: The project ID where the GCS bucket exists. You can retrieve it dynamically with:

  ```bash
  PROJECT_ID=$(gcloud config get-value project)
  ```

By listing the current IAM policies, we can verify that akash does not have any roles that allow him to interact with the GCS bucket, such as `roles/storage.objectViewer`.

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

### **Granting Full Access to akash with `roles/storage.admin`**

#### Step 4: Granting Full Access to akash

To allow **akash** (`akash@gcpbatch22.in`) full access to manage the Google Cloud Storage bucket, we will grant him the **Storage Admin** role, which provides full control over the bucket and its contents.

##### Command to Add GCS Admin Access for akash:

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:akash@gcpbatch22.in" \
    --role="roles/storage.admin"
```

- **`--member="user:akash@gcpbatch22.in"`**: Specifies the user who needs the role.
- **`--role="roles/storage.admin"`**: Grants full control over Cloud Storage, including the ability to modify objects and permissions.

#### Step 5: Verify the Role Assignment

Once you've granted the `storage.admin` role, verify that the policy has been successfully updated by checking the project's IAM policies.

##### Command to Verify the Policy:

```bash
gcloud projects get-iam-policy $PROJECT_ID --format=yaml
```

#### Step 6: akash Tries to Access GCS Again

With the `roles/storage.admin` role assigned, akash now has full control over the GCS bucket. He can:
- Create new objects in the bucket.
- Delete or modify existing objects.
- Change permissions for the bucket or its contents.

akash should log back into the GCP Console and verify that he can perform all of these actions in the GCS bucket.


