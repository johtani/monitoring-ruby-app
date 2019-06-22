# Default instance size
# Options: f1-micro, g1-small, n1-standard-1, n1-standard-2, n1-standard-4
# Override: -var 'machine_type=your-machine_type'
variable "machine_type" {
  default = "g1-small"
}

# Default GCP region
# See : https://cloud.google.com/compute/docs/regions-zones/regions-zones
variable "region" {
  default = "asia-northeast1"
}

# Default domain
# Options: You need to use your own domain that you've registered in Route53.
# Override: -var 'domain=your-domain.com'
variable "domain" {
  default = "johtani.dev"
}

# Project ID, no default
# Options: You should provide the Project ID of the domain in the environment variable TF_VAR_project_id
variable "project_id" {}

# Operating system on Google Cloud Compute Engine
# Options: Only change this at your own risk; it will probably break things.
# Override: -var 'operating_system=ubuntu-os-cloud/ubuntu-minimal-1804-lts'
variable "operating_system" {
  default = "ubuntu-os-cloud/ubuntu-minimal-1804-lts"
}

# Demo name
variable "demo_name" {
  default = "johtani-demo"
}