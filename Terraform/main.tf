# Provider for creating respurces in Google Cloud

provider "google" {
  #project = "testingiamproject-369302"
  project = var.project
  credentials = file("accounts.json")
  region = var.region
}

# Create a AUTO VPC
resource "google_compute_network" "tf_vpc_network" {
  name = "terraform-vpc-other"
}

# Create a custom VPC
resource "google_compute_network" "tf_vpc_network_custom" {
  name = "terraform-custom-network"
  auto_create_subnetworks = "false"
}

# Create a subnet
resource "google_compute_subnetwork" "tf_subnet_a" {
  # Subnet Name, Region, CIDR range, Network
  name = "subnet-a"
  region = "us-central1"
  ip_cidr_range = "10.5.0.0/16"
  network = google_compute_network.tf_vpc_network.id
  # network = "terraform-custom-network"
}

# Create firewall rules
resource "google_compute_firewall" "tf_firewall" {
  # Name, network, allow/deny, ports, source_range,destinateion, target_tags
  name = "terraform-firewall-rules"
  network = google_compute_network.tf_vpc_network.id
  # network = ${google_compute_network.tf_vpc_network.id}
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["22", "80", "1000-2000"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web"]
}

# Compute engine in terraform
# Mandatory : nw, zone,
resource "google_compute_instance" "vm_instance" {
  name = "terraform-vm"
  machine_type = "f1-micro"
  zone = var.zone
  tags = ["web"] # Networks tags at the VM level
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10" # "project/family"
      # image = data.google_compute_image.my_image.name
    }
  }
  network_interface {
    network = google_compute_network.tf_vpc_network.name
    access_config {
      # go with default , default an external ip will be created
       nat_ip = google_compute_address.static.address
    }
  }
}

# Static ip
resource "google_compute_address" "static" {
    name = "ipv4-address"
}


# Need to get the infor about the images
data "google_compute_image" "my_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

# Create  a bucket
# Unique name for the bucket

resource "google_storage_bucket" "my_bucket" {
  name = "sivagcpb13-${random_id.tf_bucket_id.dec}"
  location      = "EU" # Multi regional
  # gsutil mb -c c -l
}

# random_id
resource "random_id" "tf_bucket_id" {
    byte_length = 8
}

# State file
# GOOGLE_BACKEND_CREDENTIALS

terraform {
  backend "gcs" {
    bucket  = "testingiamproject-369302-first"
    credentials = "accounts.json"
  }
}
