provider "alicloud" {
  access_key = "YOUR_KEY"
  secret_key = "YOUR_SECRET"
  region     = "eu-west-1"
}

resource "alicloud_vpc" "vpc" {
  name       = "vpc-uk-k8s"
  cidr_block = "10.1.0.0/16"
}

resource "alicloud_vswitch" "vswitch1" {
  availability_zone = "eu-west-1a"
  name              = "vsw-uk-k8s-za-01"
  cidr_block        = "10.1.0.0/16"
  vpc_id            = "${alicloud_vpc.vpc.id}"
}

resource "alicloud_key_pair" "ecs_keys" {
  key_name = "k8s_worker_keys_demo"
  key_file = "~/.ssh/id_rsa.pub" #use the existing key pairs
}

resource "alicloud_cs_managed_kubernetes" "k8s-cluster" {
  name                      = "k8s-uk"
  vswitch_ids               = ["${alicloud_vswitch.vswitch1.id}"]
  worker_instance_types     = ["ecs.c5.large"]
  worker_disk_category      = "cloud_ssd" #cloud_ssd or cloud_efficiency
  worker_disk_size          = "40"
  worker_data_disk_category = "cloud_ssd" #cloud_ssd or cloud_efficiency
  worker_data_disk_size     = "40"
  worker_number             = 3
  key_name                  = "${alicloud_key_pair.ecs_keys.key_name}" #for ECS ssh key auth, either key_name or password
  new_nat_gateway           = true
  pod_cidr                  = "172.20.0.0/16"
  service_cidr              = "172.21.0.0/20"
  slb_internet_enabled      = true #for SLB of K8S API Server
  install_cloud_monitor     = true
  cluster_network_type      = "terway"
}
