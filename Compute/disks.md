# Disks

For better understanding do refer [here](https://cloud.google.com/compute/docs/disks/add-persistent-disk)

Create a Disk
```gcloud compute disks create (DISK_NAME) --type=(DISK_TYPE) --size=(SIZE) --zone=(ZONE)```

Resize a Disk:
```gcloud compute disks resize (DISK_NAME) --size=(SIZE) --zone=(ZONE)```

Attach a Disk
```gcloud compute instances attach-disk (INSTANCE) --disk=(DISK) --zone=(ZONE)```

## Format and resize existing disk
```bash
sudo apt install cloud-guest-utils -y
sudo growpart /dev/sda 1 # This device id may change, do refer to the documentation mentioned here[here](https://cloud.google.com/compute/docs/disks/add-persistent-disk)
sudo resize2fs /dev/sda1
```

## Attach a new Disk:
```bash
sudo lsblk
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdc
sudo mkdir -p /softwares/
sudo mount -o discard,defaults /dev/sdc /softwares/
```

## Command to get UUID
```bash
sudo blkid /dev/DEVICE_NAME
#Example
sudo blkid /dev/sdb

sudo vi /etc/fstab
UUID=5992e512-9d76-4bdf-b592-d5bd96b0ae73 /softwares   ext4    defaults          0    1

```