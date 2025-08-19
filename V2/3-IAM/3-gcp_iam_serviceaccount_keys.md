
# Google Cloud Service Accounts and Keys

## Step 1: Create a Service Account

```bash
gcloud iam service-accounts create my-service-account   --display-name="My Service Account"
```

Verify creation:
```bash
gcloud iam service-accounts list
```

---

## Step 2: Create a User-Managed Key (Optional)

```bash
gcloud iam service-accounts keys create ~/my-service-account-key.json   --iam-account=my-service-account@my-project.iam.gserviceaccount.com
```

- This downloads the private key JSON file.  
- You must keep it safe — Google will not show it again.  
- Anyone with this file can act as the service account.

---

## Step 3: List Keys for a Service Account

```bash
gcloud iam service-accounts keys list   --iam-account=my-service-account@my-project.iam.gserviceaccount.com
```

This may show keys even if you never created one. Why?  
Because Google maintains **system-managed keys**.

---

## Types of Keys

### 1. User-Managed Keys
- Created manually by you.
- JSON file downloaded once at creation.
- You are responsible for rotation and deletion.
- Check only for user-managed keys:
  ```bash
  gcloud iam service-accounts keys list     --iam-account=my-service-account@my-project.iam.gserviceaccount.com     --managed-by=user
  ```

### 2. System-Managed Keys
- Created and rotated automatically by Google.  
- Used internally for signing tokens.  
- Cannot be downloaded by users.  
- Show details with:
  ```bash
  gcloud iam service-accounts keys list     --iam-account=my-service-account@my-project.iam.gserviceaccount.com     --format='table(name, keyType, keyOrigin, validAfterTime, validBeforeTime)'
  ```

