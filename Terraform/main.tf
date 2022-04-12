# Provider to create the resource on Google Cloud 
provider "google" {
  project     = "productionproject-342002"
  region      = "us-central1"
  credentials = file("accounts.json")
}

# Create a Virtual Private Cloud (VPC)
resource "google_compute_network" "tf_vpc" {
  name = "terraform-vpc"
}

resource "google_compute_network" "tf_vpcc" {
  name = "terraform-vpcc"
  auto_create_subnetworks = false
}

# Create a subnet in terraform-vpcc 
resource "google_compute_subnetwork" "tf_subnet_custom_a" {
    name = "subnet-abc"
    # Region, CIDR range , Network 
    region        = "us-central1"
    ip_cidr_range = "10.2.0.0/16"
    network      = google_compute_network.tf_vpcc.id
}

#gcloud compute networks create terraform-vpc 

