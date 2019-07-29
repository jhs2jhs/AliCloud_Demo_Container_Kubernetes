#!/bin/bash
#
# k8s logging installer
#

set -e

export REGION_ID="cn-hangzhou"

usage()
{
	echo "usage: ./alicloud-k8s-log-installer.sh [option]"
	echo "option:"
	echo "    --cluster-id    k8s cluster id [required]"
	echo "    --region-id     region id [optional, default is cn-hangzhou]"
	echo "    --ali-uid       ali uid [required]"
	echo "    --log-project   log service project name [optional]"
	echo "    --kube-config   kubeconfig path [optional, default is $HOME/.kube/config]"
}

cleanup()
{
	rm -rf ./alibaba-cloud-log.tgz
}

while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
	--cluster-id)
		export CLUSTER_ID=$2
		shift
		;;
	--region-id)
		export REGION_ID=$2
		shift
		;;
	--ali-uid)
		export ALIUID=$2
		shift
		;;
	--log-project)
		export LOG_PROJECT=$2
		shift
		;;
	--kube-config)
		export KUBE_CONFIG=$2
		shift
		;;
	*)
		echo "[FAIL] unknown option [$key]"
		usage
		exit 1
		;;
	esac
	shift
done

if [ -z "$CLUSTER_ID" ]; then
	echo "[FAIL] missing option [--cluster-id]"
	usage
	exit 1
fi

if [ -z "$REGION_ID" ]; then
	echo "[FAIL] missing option [--region-id]"
	usage
	exit 1
fi

if [ -z "$ALIUID" ]; then
	echo "[FAIL] missing option [--ali-uid]"
	usage
	exit 1
fi

clusterName=$(echo $CLUSTER_ID | tr '[A-Z]' '[a-z]')

if [ -z "$LOG_PROJECT" ]; then
	export LOG_PROJECT="k8s-log-"$clusterName
fi

helmPackageUrl="http://logtail-release-$REGION_ID.oss-$REGION_ID.aliyuncs.com/kubernetes/alibaba-cloud-log.tgz"
if [ "$REGION_ID" = "cn-shenzhen-finance-1" ]; then
    helmPackageUrl="http://logtail-release-$REGION_ID.oss-cn-szfinance-a.aliyuncs.com/kubernetes/alibaba-cloud-log.tgz"
fi

wget $helmPackageUrl -O alibaba-cloud-log.tgz

if [ $? != 0 ]; then
    echo "[FAIL] download alibaba-cloud-log.tgz from $helmPackageUrl failed"
    exit 1
fi

trap cleanup EXIT

if [ -n "$KUBE_CONFIG" ]; then
	export KUBECONFIG=$KUBE_CONFIG
fi

echo "[INFO] your k8s is using project : $LOG_PROJECT"
if [ "$REGION_ID" = "cn-shenzhen-finance-1" ]; then
    helm install alibaba-cloud-log.tgz --name alibaba-log-controller \
        --set ProjectName=$LOG_PROJECT \
        --set RegionId="cn-shenzhen-finance" \
        --set InstallParam="cn-shenzhen-finance" \
        --set MachineGroupId="k8s-group-"$clusterName \
        --set Endpoint="cn-shenzhen-finance-intranet.log.aliyuncs.com" \
        --set AlibabaCloudUserId=":"$ALIUID \
        --set LogtailImage.Repository="registry-vpc.$REGION_ID.aliyuncs.com/acs/logtail" \
        --set LogtailImage.Tag="0.16.14.0-6d1f710-aliyun" \
        --set ControllerImage.Repository="registry-vpc.$REGION_ID.aliyuncs.com/acs/log-controller" \
        --set ControllerImage.Tag="0.1.0.0-a66d1d2-aliyun"
else
    helm install alibaba-cloud-log.tgz --name alibaba-log-controller \
        --set ProjectName=$LOG_PROJECT \
        --set RegionId=$REGION_ID \
        --set InstallParam=$REGION_ID \
        --set MachineGroupId="k8s-group-"$clusterName \
        --set Endpoint=$REGION_ID"-intranet.log.aliyuncs.com" \
        --set AlibabaCloudUserId=":"$ALIUID \
        --set LogtailImage.Repository="registry.$REGION_ID.aliyuncs.com/log-service/logtail" \
        --set ControllerImage.Repository="registry.$REGION_ID.aliyuncs.com/log-service/alibabacloud-log-controller"
fi

installRst=$?
if [ $installRst -eq 0 ]; then
    echo "[SUCCESS] install helm package : alibaba-log-controller success."
    exit 0
else
    echo "[FAIL] install helm package failed, errno " $installRst
    exit 0
fi
