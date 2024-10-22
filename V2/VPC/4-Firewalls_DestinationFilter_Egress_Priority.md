
# Google Cloud Egress Control with Destination Filters and Firewall Rule Priorities

## Example: Egress Control with Destination Filters and Firewall Rule Priorities

---

### Step 1: Create Two VMs

We will create two VMs in the same subnet. One VM (`vm-allow-google`) will be allowed to ping Google's DNS server (`8.8.8.8`), while the other VM (`vm-deny-google`) will be blocked.

```bash
# Create VM1 (allowed to ping Google)
gcloud compute instances create vm-allow-google \
    --zone us-central1-a \
    --subnet=subnet-b \
    --machine-type=e2-medium \
    --tags=allow-ping-google

# Create VM2 (denied from pinging Google)
gcloud compute instances create vm-deny-google \
    --zone us-central1-a \
    --subnet=subnet-b \
    --machine-type=e2-medium
```

#### Explanation:
- **vm-allow-google** has the tag `allow-ping-google` and will be allowed to ping Google.
- **vm-deny-google** will not be tagged and will be blocked from pinging Google.

---

### Step 2: Set Up Egress Firewall Rules with Destination Filters

We will now create two egress rules:
1. **Allow ICMP traffic to Google (8.8.8.8) for `vm-allow-google`.**
2. **Block all ICMP traffic to Google (8.8.8.8) for all other VMs** using priority.

---

#### Rule 1: Allow Egress ICMP to Google for `vm-allow-google`

```bash
gcloud compute firewall-rules create allow-ping-google \
    --direction=EGRESS \
    --priority=900 \
    --network=custom-network \
    --action=ALLOW \
    --rules=icmp \
    --destination-ranges=8.8.8.8/32 \
    --target-tags=allow-ping-google
```

#### Explanation:
- **Priority**: `900` (lower priority number means higher precedence).
- **Action**: Allows ICMP traffic to the destination range `8.8.8.8/32` (Google's DNS).
- **Target Tags**: Applies only to VMs with the tag `allow-ping-google`, i.e., `vm-allow-google`.

---

#### Rule 2: Deny Egress ICMP to Google for All Other VMs

```bash
gcloud compute firewall-rules create deny-ping-google \
    --direction=EGRESS \
    --priority=1000 \
    --network=custom-network \
    --action=DENY \
    --rules=icmp \
    --destination-ranges=8.8.8.8/32
```

#### Explanation:
- **Priority**: `1000` (a higher number than `900`, so it only applies if the allow rule doesn’t match).
- **Action**: Denies ICMP traffic to the destination range `8.8.8.8/32`.
- This applies to all VMs that do **not** have the `allow-ping-google` tag.

---

### Step 3: Test Egress Traffic

1. **SSH into `vm-allow-google`**:

   ```bash
   gcloud compute ssh --zone us-central1-a vm-allow-google
   ```

   Once inside the VM, try to ping Google's DNS server (`8.8.8.8`):

   ```bash
   ping 8.8.8.8
   ```

   **Expected Result**: The ping should be successful, as the egress rule with a priority of `900` allows this VM to send ICMP traffic to `8.8.8.8`.

2. **SSH into `vm-deny-google`**:

   ```bash
   gcloud compute ssh --zone us-central1-a vm-deny-google
   ```

   Try to ping Google's DNS server (`8.8.8.8`):

   ```bash
   ping 8.8.8.8
   ```

   **Expected Result**: The ping should fail because the deny rule with a priority of `1000` blocks ICMP traffic to `8.8.8.8` for all VMs without the `allow-ping-google` tag.

---

### Step 4: Clean Up Resources

After testing, clean up the VMs and firewall rules:

```bash
# Delete the VMs
gcloud compute instances delete vm-allow-google vm-deny-google --zone us-central1-a --quiet

gcloud compute instances delete vm-deny-google vm-deny-google --zone us-central1-a --quiet


# Delete the firewall rules
gcloud compute firewall-rules delete allow-ping-google deny-ping-google --quiet

# Delete subnet-a
gcloud compute networks subnets delete subnet-a \
    --region=us-central1 --quiet

# Delete subnet-b
gcloud compute networks subnets delete subnet-b \
    --region=us-central1 --quiet

# Delete the custom VPC
gcloud compute networks delete custom-network --quiet

```

---

## Key Concepts Highlighted in This Example

- **Destination Filters**: The `destination-ranges` field limits the egress traffic to Google's DNS server IP `8.8.8.8/32`.
- **Network Tags**: The firewall rules use network tags (`allow-ping-google`) to selectively allow traffic from specific VMs.
- **Priority**: The priority of the firewall rules determines which rule is applied first. In this case, the allow rule (priority `900`) takes precedence over the deny rule (priority `1000`) for the tagged VM.

---

## Summary:
- **VM1 (`vm-allow-google`)** is allowed to send ICMP (ping) traffic to Google's DNS server (`8.8.8.8`) based on a firewall rule with a destination filter and higher priority.
- **VM2 (`vm-deny-google`)** is denied from sending ICMP traffic to Google's DNS server based on a lower-priority deny rule.
- The use of **egress rules**, **destination filters**, and **priority** ensures that traffic is allowed or blocked as needed.
