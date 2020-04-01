provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}

data "yandex_compute_image" "ubuntu1804" {
  family = "ubuntu-1804-lts"
}

resource "yandex_compute_instance" "mydefault" {
  name        = var.name
  platform_id = "standard-v1"
  zone        = var.zone
  hostname    = var.name

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu1804.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.mydefault.id
    nat       = true
  }

  metadata = {
    user-data = templatefile(
      "metadata.tpl",
      {
        username   = var.user,
        public_key = file(var.public_key_path),
        hostname   = var.name
      }
    )
  }
}

resource "yandex_vpc_network" "mydefault" {
}

resource "yandex_vpc_subnet" "mydefault" {
  zone           = var.zone
  network_id     = yandex_vpc_network.mydefault.id
  v4_cidr_blocks = ["10.100.1.0/24"]
}

output "external_ip" {
  value = yandex_compute_instance.mydefault.network_interface.0.nat_ip_address
}
output "metadata" {
  value = yandex_compute_instance.mydefault.metadata
}
