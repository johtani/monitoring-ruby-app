# Google provider settings
# You MUST set GCP service account key file to GOOGLE_APPLICATION_CREDENTIALS env param.
# Need gcloud command
provider "google" {
  project     = "${var.project_id}"
  region      = "${var.region}"
}

# For get zone list
data "google_compute_zones" "available" {}

# Network settings
resource "google_compute_firewall" "default" {
  name    = "demo-firewall"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "3000", "5432"]
  }

  source_tags = ["web"]
}

resource "google_compute_network" "default" {
  name = "test-network"
}

# DNS zone settings
resource "google_dns_managed_zone" "demo_domain" {
  name        = "demo-domain-zone"
  dns_name    = "${var.domain}."
}

# create the database instance
resource "google_compute_instance" "database" {
  name         = "database-johtani-demo"
  machine_type = "${var.machine_type}"
  zone         = "${data.google_compute_zones.available.names[0]}"
  tags         = ["database"]
  boot_disk {
    initialize_params {
      image = "${var.operating_system}"
    }
  }
  network_interface {
    network       = "default"
    access_config {}
  }
}

## database DNS entries
resource "google_dns_record_set" "database" {
  name         = "backend.${google_dns_managed_zone.demo_domain.dns_name}"
  managed_zone = "${google_dns_managed_zone.demo_domain.name}"
  type         = "A"
  ttl          = 60
  rrdatas      = [ "${google_compute_instance.database.network_interface.0.access_config.0.nat_ip}" ]
}

# create the frontend instance

resource "google_compute_instance" "frontend" {

  name         = "frontend-johtani-demo"
  machine_type = "${var.machine_type}"
  zone         = "${data.google_compute_zones.available.names[0]}"
  tags         = ["frontend"]
  boot_disk {
    initialize_params {
      image = "${var.operating_system}"
    }
  }
  network_interface {
    network       = "default"
    access_config {}
  }
}

## frontend DNS entries
resource "google_dns_record_set" "frontend" {
  name         = "frontend.${google_dns_managed_zone.demo_domain.dns_name}"
  managed_zone = "${google_dns_managed_zone.demo_domain.name}"
  type         = "A"
  ttl          = 60
  rrdatas      = [ "${google_compute_instance.frontend.network_interface.0.access_config.0.nat_ip}" ]
}

resource "google_dns_record_set" "www" {
  name         = "www.${google_dns_managed_zone.demo_domain.dns_name}"
  managed_zone = "${google_dns_managed_zone.demo_domain.name}"
  type         = "A"
  ttl          = 60
  rrdatas      = [ "${google_compute_instance.frontend.network_interface.0.access_config.0.nat_ip}" ]
}