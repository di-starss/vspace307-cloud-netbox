//
// CORE
//
terraform {
  required_providers {
    netbox = {
      source = "e-breuninger/netbox"
      version = "0.2.2"
    }
  }
}


//
// VARIABLES
//
variable "env" {
  description = "dev"
  type = string
}

variable "project" {
  description = "vdb"
  type = string
}

variable "service" {
  description = "core"
  type = string
}

variable "site" {
  description = "ams1"
  type = string
}

variable "prefix" {
  description = "172.28.85.0/24"
  type = string
}

variable "cluster" {
  description = "demo-lab"
  type = string
}

variable "domain" {
  description = "cloud.vspace307.io"
  type = string
}

variable "vm_name" {
  description = "db-core-master"
  type = string
}

variable "vm_interface" {
  description = "eth0"
  type = string
}


//
// DATA
//
data "netbox_prefix" "prefix" {
  cidr = var.prefix
}

data "netbox_cluster" "cluster" {
  name = var.cluster
}


//
// RESOURCE
//

// fqdn: master.core.dev.vdb.ams1.cloud.vspace307.io
resource "netbox_virtual_machine" "vm" {
  cluster_id = data.netbox_cluster.cluster.id
  name = lower(join(".", [var.vm_name, var.service, var.env, var.project, var.site, var.domain]))
}

resource "netbox_interface" "vm_interface" {
  name = var.vm_interface
  virtual_machine_id = netbox_virtual_machine.vm.id
}

resource "netbox_available_ip_address" "vm_ip" {
  prefix_id = data.netbox_prefix.prefix.id
  interface_id = netbox_interface.vm_interface.id
  status = "active"
}

resource "netbox_primary_ip" "vm_primary" {
  virtual_machine_id = netbox_virtual_machine.vm.id
  ip_address_id = netbox_available_ip_address.vm_ip.id
}


//
// OUTPUT
//
locals  {
  ip = element(split("/", netbox_available_ip_address.vm_ip.ip_address),0)
}

output "vm_ip" {
  value = local.ip
}

output "vm_name" {
  value = var.vm_name
}

output "vm_fqdn" {
  value = netbox_virtual_machine.vm.name
}

output "vm_subnet" {
  value = var.prefix
}

output "vm_hostname" {
  value = lower("${var.vm_name}-${var.service}-${var.env}-${var.project}-${var.site}")
}

output "dns_record" {
  value = "${netbox_virtual_machine.vm.name}."
}

output "dns_zone" {
  value = "${var.domain}."
}

output "env" {
  value = var.env
}

output "service" {
  value = var.service
}

output "project" {
  value = var.project
}

output "site" {
  value = var.site
}

