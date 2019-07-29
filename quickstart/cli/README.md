# Quick start with ACK

In this guide, we will create a managed Kubernetes cluster with ACK.

Please make sure you have [aliyun-cli](https://github.com/aliyun/aliyun-cli) installed and configured.

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


1. Create a VPC

We will use resources in the UK region, so we set an environment variable `REGION_ID` with value `eu-west-1`.

```
REGION_ID=eu-west-1
```

Let's create a VPC called `vpc-uk-k8s` in `UK` region with CIDR `172.16.0.0/12`

```
aliyun vpc CreateVpc \
  --VpcName vpc-uk-k8s \
  --Description "K8s clusters live here" \
  --RegionId ${REGION_ID} \
  --CidrBlock 10.1.0.0/16
```

```json
{
	"RequestId": "5D7C65DF-68A0-447B-9E83-B6EB6C0582CA",
	"ResourceGroupId": "rg-acfmvshpwxs3g6a",
	"RouteTableId": "vtb-d7ojbtmz2f4801t3aot3f",
	"VpcId": "vpc-d7omcfk70ym1ll5qozznt",
	"VRouterId": "vrt-d7o1z7hazqb19k9ntae6i"
}
```

We use another variable `VPC_ID` to record the VPC ID.

```
VPC_ID=vpc-d7omcfk70ym1ll5qozznt
```

2. Create a VSwitch in UK region zone a

```
aliyun vpc CreateVSwitch \
    --VSwitchName vsw-uk-k8s-za-01 \
    --Description "K8s vSwitch in UK zone a" \
    --VpcId    ${VPC_ID} \
    --RegionId ${REGION_ID} \
    --ZoneId   ${REGION_ID}a \
    --CidrBlock 10.1.1.0/24
```

```json
{
	"RequestId": "A11D5D85-E555-4E43-B74E-FC9E3936AEC9",
	"VSwitchId": "vsw-d7or8bzu1cpypapjgth4l"
}
```

Let's do the same to record the VSwitch ID in `VSW_ID`.

```
VSW_ID=vsw-d7or8bzu1cpypapjgth4l
```

3. Import a key pair for ECS access

You can also use password but key pairs are recommended.

```
aliyun ecs ImportKeyPair \
    --KeyPairName ecs_keys \
    --RegionId ${REGION_ID} \
    --PublicKeyBody "$(cat ~/.ssh/id_rsa.pub)"
```

```json
{
	"RequestId": "F7F2A4D8-6FFF-4344-8674-AD630C79DB50",
	"KeyPairFingerPrint": "abecc1a30afb64644745a257a1206a6f",
	"KeyPairName": "ecs_keys"
}
```

4. Create a managed K8s cluster

We will first construct a `JSON` object file called `k8s_cluster.json` with parameters needed for creating the cluster.

```json
cat << EOF > cluster.json
{
    "name": "k8s-uk",
    "region_id": "${REGION_ID}",
    "zoneid": "${REGION_ID}a",
    "vpcid": "${VPC_ID}",
    "vswitchid": "${VSW_ID}",
    "container_cidr": "172.20.0.0/16",
    "service_cidr": "172.21.0.0/20",
    "cluster_type": "ManagedKubernetes",
    "cloud_monitor_flags": true,
    "disable_rollback": true,
    "timeout_mins": 60,
    "snat_entry": true,
    "cloud_monitor_flags": false,
    "public_slb": true,
    "worker_instance_type": "ecs.c5.large",
    "worker_instance_charge_type": "PostPaid",
    "worker_system_disk_category": "cloud_efficiency",
    "worker_system_disk_size": 120,
    "num_of_nodes": 3,
    "key_pair": "ecs_keys"
}
EOF
```

```
aliyun cs POST /clusters \
    --header "Content-Type=application/json" \
    --body "$(cat cluster.json)"
```
