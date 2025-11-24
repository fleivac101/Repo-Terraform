## Plantilla específica para la creación de una máquina virtual con 2 discos mediante clonación ##
## de un Template existente en VMWare ##

data "vsphere_datacenter" "datacenter" {
  name = var.datacenter_name
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.cpu_number
  memory           = var.memory_amount
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  scsi_controller_count = data.vsphere_virtual_machine.template.scsi_controller_scan_count
  firmware         = data.vsphere_virtual_machine.template.firmware
  wait_for_guest_net_timeout = -1
  memory_hot_add_enabled = true
  num_cores_per_socket = var.cpu_number
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.disk_size_0
  }

  clone {
      template_uuid = data.vsphere_virtual_machine.template.id
      customize {
        windows_options {
          computer_name = var.host_name          
        }
        network_interface {
          ipv4_address = var.ip_address
          ipv4_netmask = 24
        }
        ipv4_gateway = var.gateway   # 🔹 agregar esto
      }
     }
    }





