provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

data "yandex_compute_image" "reddit" {
  family = var.family
  folder_id = var.folder_id # If you specify family without folder_id then lookup takes place in the 'standard-images' folder.
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
      image_id = data.yandex_compute_image.reddit.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.mydefault.id
    nat       = "true"
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

  connection {
    type        = "ssh"
    host        = yandex_compute_instance.mydefault.network_interface.0.nat_ip_address
    user        = var.user
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y git",
      "git clone -b monolith https://github.com/express42/reddit.git",
      "cd reddit && bundle install",
      "puma -d"
    ]
  }
}

resource "yandex_vpc_network" "mydefault" {
  name = "mydefault"
}

resource "yandex_vpc_subnet" "mydefault" {
  zone           = var.zone
  network_id     = yandex_vpc_network.mydefault.id
  v4_cidr_blocks = ["10.100.1.0/24"]
}

output "external_ip" {
  value = yandex_compute_instance.mydefault.network_interface.0.nat_ip_address
}