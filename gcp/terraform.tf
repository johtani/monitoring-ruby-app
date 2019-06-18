provider "google" {
  project     = "${var.project_id}"
  region      = "${var.region}"
}

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


# create the database instance

resource "google_compute_instance" "database" {
  
  name         = "backend-johtani-demo"
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