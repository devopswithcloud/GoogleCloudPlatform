# SSH Keys in Google Compute Engine (GCE)

## 1.  Why SSH Keys? 

* Each  Linux VM instance  requires a  private key (local machine)  and a  public key (on server)  to allow access.
* The login works when:
   Private key (your machine)  🔗  Public key (stored on VM metadata in GCP) .

---

## 2.  Where are SSH Keys stored in GCP? 

* In the  Metadata section  of VM Instances.
* Metadata = programmatic access to instance info + custom values.
* Stored as  Key\:Value pairs  (example: `ssh-keys=user:ssh-rsa ...`).

👉 Keys can be set at two levels:

1.  Project-level metadata  → Keys apply to  all VMs  in the project.
2.  Instance-level metadata  → Keys apply to  only that VM .

---

## 3.  Two Methods of SSH Access 

### 🔹 A. Google-managed SSH Keys

* Works automatically via  Console  or  gcloud CLI .
* No manual key creation needed.
* Example:

  ```bash
  gcloud compute ssh <instance-name> --zone=<zone>
  ```

### 🔹 B. Custom SSH Keys

* Manual process:

  1. Generate your own key pair.
  2. Add the  public key  to instance/project metadata.
  3. Connect using the  private key .
* Example:

  ```bash
  ssh -i ~/.ssh/my-ssh-key <username>@<external-ip>
  ```

---

## 4.  Creating Custom SSH Keys 

### Linux / macOS

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/my-ssh-key -C "your-username"
```

### Windows (PowerShell / Git Bash)

```bash
ssh-keygen -t rsa -b 4096 -f C:\Users\<YourUser>\.ssh\my-ssh-key -C "your-username"
```

👉 This creates:

* `my-ssh-key` →  Private key 
* `my-ssh-key.pub` →  Public key 

---

## 5.  Important Flags in `ssh-keygen` 

* `-t rsa` → type of key (RSA).
* `-b 4096` → number of bits (key length).

  * 2048 bits → standard secure.
  * 4096 bits → stronger encryption (recommended).
* `-f <path>` → file name/path for the key.
* `-C "comment"` → optional comment (usually username/email).

---

## 6.  Adding Keys to GCE 

### Option A: Project-wide

```bash
gcloud compute project-info add-metadata \
  --metadata-from-file ssh-keys=~/.ssh/my-ssh-key.pub
```

### Option B: Specific VM

```bash
gcloud compute instances add-metadata <VM-NAME> \
  --zone=<ZONE> \
  --metadata-from-file ssh-keys=~/.ssh/my-ssh-key.pub
```

---

## 7.  Best Practices 

*  Use  per-user keys  (not shared).
* Prefer  OS Login  (IAM-managed, centralized).
* Rotate keys regularly.
* Never store private keys in GitHub/cloud storage.

