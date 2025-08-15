
# Google Cloud IAM

## 1. What is IAM?

* Google Cloud IAM (Identity and Access Management) is a service that helps you control who (identity) can do what (role/permission) on which resource.
* It ensures that only the right people or services have the right level of access to your Google Cloud resources.

IAM answers **three core areas**:

* **Who** → The identity (user, group, service account, etc.) making the request.
* **What Role** → The collection of permissions granted.
* **On Which Resource** → The specific GCP resource being accessed.

---

## 2. Key Components of IAM

### 2.1 Who (Identities / Members)

Identities are entities that can be granted access to resources.

**Types of Members in GCP IAM:**

1. **Google Account (User)** → Example: `alice@gmail.com`
2. **Google Group** → A set of Google accounts. Example: `devops-team@company.com`
3. **Service Account** → Used by applications or VMs to interact with GCP APIs.
4. **Google Workspace / Cloud Identity Domain** → Example: `@company.com`
5. **All Authenticated Users** → Any logged-in Google account user.
6. **All Users** → Anyone on the internet (public access).

---

### 2.2 Roles (Collection of Permissions)

Permissions in IAM are **not** assigned directly to members — they are grouped into **roles**.

#### **Types of Roles in GCP:**

1. **Primitive Roles (Basic Roles)** – Legacy, project-wide:

   * **Owner (`roles/owner`)** → Full control, including IAM changes.
   * **Editor (`roles/editor`)** → Create, modify, delete resources (no IAM changes).
   * **Viewer (`roles/viewer`)** → Read-only access.

2. **Predefined Roles** – Granular roles for specific services:

   * Managed by Google, updated as services evolve.
   * Example:

     * `roles/storage.objectViewer` → View objects in GCS.
     * `roles/compute.instanceAdmin.v1` → Manage Compute Engine VMs.
   * Advantage: **Least privilege** principle is easier to follow.

3. **Custom Roles** – Fully tailored:

   * Created by admins with only the exact permissions needed.
   * Example: Role allowing only VM start/stop without delete or create permissions.

---

### 2.3 Permissions

* The smallest unit of IAM.
* Format: `service.resource.verb`

  * Example: `compute.instances.start`, `storage.buckets.list`
* Roles = **Set of permissions**
* Permissions **cannot** be assigned directly to a member — they must be part of a role.

---

## 3. Resources in IAM

* Every object in GCP that can be managed via IAM is called a **resource**.
* Examples:

  * Project
  * Compute Engine VM
  * Cloud Storage Bucket
  * BigQuery Dataset
* IAM policies are attached **at the resource level**.
* IAM follows a **resource hierarchy**:

  ```
  Organization → Folder → Project → Resource
  ```

  * Policies are **inherited** down the hierarchy unless overridden.

---

## 4. Service Accounts (SAs)

### 4.1 What is a Service Account?

* A **special type of Google account** for **applications, VMs, or workloads** to authenticate and call GCP APIs.
* Not for human use.
* Has its own unique email format:
  `service-account-name@project-id.iam.gserviceaccount.com`

### 4.2 Types of Service Accounts

1. **User-Managed** → Created and controlled by you.
2. **Default Service Accounts** → Auto-created by GCP when you use certain services (e.g., Compute Engine default SA).
3. **Google-Managed** → Used internally by Google services on your behalf.

---

### 4.3 Service Account Keys

* **Definition:** A private key file (JSON) used to authenticate a service account **outside GCP**.
* **Usage:** For local development, CI/CD pipelines, or external systems calling GCP APIs.
* **Risks:** Keys can be stolen → Leads to security breaches.
* **Best Practices:**

  * Avoid long-lived keys.
  * Rotate and delete unused keys.

---

## 5. IAM Best Practices

* Apply **Principle of Least Privilege** — give only required permissions.
* Prefer **predefined roles** over primitive roles.
* Avoid granting `allUsers` unless absolutely necessary.
* Regularly **review IAM policies**.
* Use **custom roles** when predefined roles have unnecessary permissions.
* Minimize or avoid using service account keys; prefer GCP-native authentication.

