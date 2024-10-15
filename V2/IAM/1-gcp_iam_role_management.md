
# GCP IAM Role Management with gcloud Commands

## Scenarios Covered:
1. **Create a Custom IAM Role Using a YAML File**  
2. **Verify the Created Role Using gcloud and Google Cloud Console**  
3. **Create a Custom IAM Role Using Command-Line Arguments**  
4. **Add Permissions to an Existing Role**  
5. **Remove Permissions from an Existing Role**  
6. **Verify Role Modifications**  

---

### Step 1: Get the Dynamic Project ID
Retrieve the active project ID dynamically from your gcloud configuration:

```bash
PROJECT_ID=$(gcloud config get-value project)
```

---

### Step 2: Create the YAML file for the Custom Role
Save the following content in a file named `iam-roles.yaml`:

```yaml
title: "i27customrole1"
description: "Custom Role to create Instances"
stage: "GA"
includedPermissions:
  - compute.instances.create 
  - compute.acceleratorTypes.list
  - compute.disks.create
  - compute.disks.list
  - compute.instances.create
  - compute.instances.list
  - compute.instances.setServiceAccount
  - compute.machineTypes.list
  - compute.networks.get
  - compute.networks.list
  - compute.projects.get
  - compute.regions.list
  - compute.subnetworks.get
  - compute.subnetworks.list
  - compute.subnetworks.use
  - compute.subnetworks.useExternalIp
  - compute.zones.list
```

---

### Step 3: Create the Custom IAM Role from YAML
Run the following command to create the custom role using the `iam-roles.yaml` file:

```bash
gcloud iam roles create i27customrole1     --project $PROJECT_ID     --file iam-roles.yaml
```

---

### Step 4: Verify the Role Creation via gcloud
To verify the custom role you just created, run:

```bash
gcloud iam roles describe i27customrole1 --project $PROJECT_ID
```

---

### Step 5: Verify the Role in the Google Cloud Console
Additionally, you can verify the created role in the Google Cloud Console:
- Navigate to **IAM & Admin** > **Roles** under your project.
- Look for the custom role `i27customrole1` to confirm its creation and permissions.

---

### Step 6: Create a Custom Role Using Arguments

You can also create a custom role using command-line arguments directly:

```bash
# Available stages for roles:
# ALPHA: Role is in early testing phase, may change.
# BETA: Role is more stable but still subject to changes.
# GA (General Availability): Role is fully available and stable for use.

gcloud iam roles create i27customrole4 \
  --project $PROJECT_ID \
  --permissions=compute.instances.create,compute.acceleratorTypes.list,compute.disks.create \
  --title="i27customrole2" \
  --description="Custom Role 2 from arguments" \
  --stage="GA"
```

---

### Step 7: Verify the Custom Role Created via Arguments

```bash
gcloud iam roles describe i27customrole4 --project $PROJECT_ID
```

---

### Step 8: Verify the Role in the Google Cloud Console
- Navigate to **IAM & Admin** > **Roles** under your project to confirm the role creation.

---

### Step 9: Add Permissions to the Custom Role

You can add additional permissions to the existing custom role `i27customrole4`:

```bash
gcloud iam roles update i27customrole4     --project $PROJECT_ID     --add-permissions="compute.networks.get"
```

---

### Step 10: Verify the Updated Role

After adding the permission, describe the role again to verify the updated permissions:

```bash
gcloud iam roles describe i27customrole4 --project $PROJECT_ID
```

---

### Step 11: Remove Permissions from the Custom Role

To remove the `compute.networks.get` permission that you just added, use this command:

```bash
gcloud iam roles update i27customrole4     --project $PROJECT_ID     --remove-permissions="compute.networks.get"
```

---

### Step 12: Verify the Role After Removing the Permission

Once again, describe the role to ensure the permission was removed successfully:

```bash
gcloud iam roles describe i27customrole4 --project $PROJECT_ID
```

---

### Role Stages Explanation:
- **ALPHA**: Role is in early development, changes are expected.
- **BETA**: Role is more stable but might still undergo changes.
- **GA (General Availability)**: Role is fully supported and stable.

---
