## Datos de Login ##

variable "vsphere_user" {
  description = "Usuario de Conexión"
  type = string
}

variable "vsphere_password" {
  description = "Contraseña del Usuario"
  type = string
}


variable "vsphere_server" {
  description = "IP del VCenter"
  type = string
}

## Datos del vSphere ##

# Son variables de qué recursos del vCenter utilizará la máquina virtual #
variable "datacenter_name" {
  description = "Nombre del Data Center"
  type = string
}

variable "datastore_name" {
  description = "Nombre del Data Store"
  type = string
}

variable "cluster_name" {
  description = "Nombre del Cluster"
  type = string
}

variable "network_name" {
  description = "Nombre de la Network"
  type = string
}
## Datos del vSphere ##

## Datos de la customización de la Máquina Virtual ##
## Son datos de las caracteristicas de Hardware y S.O. de la máquina ##
variable "disk_size_0" {
  description = "Tamaño del Disco 0"
  type = number
}

variable "template_name" {
  description = "Nombre del Template de la Maquina Virtual"
  type = string
}

variable "vm_name" {
  description = "Nombre de la Maquina Virtual a nivel de VMWare"
  type = string
}

variable "cpu_number" {
  description = "Numero de CPUs"
  type = number
}

variable "memory_amount" {
  description = "Cantidad de Memoria de la Maquina"
  type = number
}

variable "host_name" {
  description = "Nombre de la Máquina a Nivel de S.O."
  type = string
}

variable "host_domain" {
  description = "Dominio de la Máquina a Nivel de S.O."
  type = string
}

variable "ip_address" {
  description = "Direccion IP de la Maquina"
  type = string
}

variable "gateway" {
  description = "Dirección IPv4 del Gateway"
  type        = string
 }
## Datos de la customización de la Máquina Virtual ##
