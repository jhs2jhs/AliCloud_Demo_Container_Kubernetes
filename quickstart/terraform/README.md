# ACK Quick start with Terraform

Alibaba Cloud has rapid integration cycles with [Terraform](https://www.terraform.io/docs/providers/alicloud/). In this guide, we will create a managed Kubernetes cluster with TerraForm.

Please make sure you have [Terraform](https://www.terraform.io/downloads.html) installed.

Let's go!

# Which one to choose?

ACK provides three major varieties, they have different management levels.

| Type       | Master | Worker |
|------------|-------:| ------:|
| Serverless |    Yes |    Yes |
| Managed    |     No |    Yes |
| Dedicated  |     No |     No |

Take the managed Kubernetes cluster as an example, the users don't need to manage and pay for the master nodes.

More details are described [here](https://www.alibabacloud.com/help/doc-detail/107720.htm).

# Create a managed Kubernetes cluster

Managed K8s cluster is a very popular option as it gives users control of the worker nodes but keep the master nodes transparent which made life a little bit easier (less to manage, less to pay for).

The K8s cluster will reside in a VPC, the nodes can be put into one or more VSwitches. For the simplicity, we will create one VPC and one VSwitch only.

1. Configure the cloud provider

We will use resources in the UK region, so we set the region to `eu-west-1`.

```terraform
provider "alicloud" {
  access_key = "LTAI1q4uP7X9myAC"                 # The AccessKey ID
  secret_key = "LhEHACRDbYHGWQhZ6giWRSRc4KKZmu"   # AccessKey Secret
  region     = "eu-west-1"
}
```

2. Create a VPC

Let's create a VPC called `vpc-uk-k8s` in `UK` region with CIDR `10.1.0.0/16`.

Beware of the CIDR ranges, take a look [here for CIDR planing](https://www.alibabacloud.com/help/doc-detail/86500.htm).

```terraform
resource "alicloud_vpc" "vpc" {
  name       = "vpc-uk-k8s"
  cidr_block = "10.1.0.0/16"
}
```

2. Create a VSwitch in UK region zone `a`

```terraform
resource "alicloud_vswitch" "vswitch1" {
  name              = "vsw-uk-k8s-za-01"
  availability_zone = "eu-west-1a"
  cidr_block        = "10.1.0.0/16"
  vpc_id            = "${alicloud_vpc.vpc.id}"
}
```

3. Import a key pair for ECS access

You can also use password but key pairs are recommended.

```terraform
resource "alicloud_key_pair" "ecs_keys" {
  key_name = "k8s_worker_keys"
  key_file = "~/.ssh/id_rsa.pub"  # Use the existing key pairs
}
```

4. Create a managed K8s cluster

```terraform
resource "alicloud_cs_managed_kubernetes" "k8s-cluster" {
  name                      = "k8s-uk"
  vswitch_ids               = ["${alicloud_vswitch.vswitch1.id}"]
  worker_instance_types     = ["ecs.c5.large"]
  worker_disk_category      = "cloud_efficiency"  # cloud_ssd or cloud_efficiency
  worker_disk_size          = "40"
  worker_data_disk_category = "cloud_ssd"         # cloud_ssd or cloud_efficiency
  worker_data_disk_size     = "40"
  worker_numbers            = [3]
  key_name                  = "${alicloud_key_pair.ecs_keys.key_name}" #for ECS ssh key auth, either key_name or password
  new_nat_gateway           = "true"
  pod_cidr                  = "172.20.0.0/16"
  service_cidr              = "172.21.0.0/20"
  slb_internet_enabled      = "true"              # for SLB of K8S API Server
  install_cloud_monitor     = "true"
  cluster_network_type      = "terway"
}
```

5. Init and apply

Run the following to deploy all the resources.

```
terraform init
terraform apply
```
