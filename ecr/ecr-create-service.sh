#!/bin/bash
# requirement : awscli, jq
command -v aws >/dev/null 2>&1 || { echo "We require awscli but it's not installed.  Aborting." >&2; exit 1; }
command -v ecs-cli >/dev/null 2>&1 || { echo "We require ecs-cli but it's not installed.  Aborting." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "We require jq but it's not installed.  Aborting." >&2; exit 1; }

set -x

[ -z "$1" ] && { echo "Please specify aws elb input cli json filename."; exit 1; }
[ -z "$2" ] && { echo "Please specify teamName. (e.g. Steam)"; exit 1; }

[ -f docker-compose.yml ] || { echo "Where is the docker-compose.yml OR docker-compose.noversion.yml file??"; exit 1; }

export HOME=$(pwd)

SERVICE_NAME=$(jq -r .serviceName <$1)
CLUSTER=$(jq -r .cluster <$1)

ecs-cli configure --region us-west-2 --cluster dev --compose-project-name-prefix $2- --compose-service-name-prefix ${2}- --cfn-stack-name-prefix ecsagent-cli-


if [[ $(cat *.conf|wc -c) -gt 0 ]]; then
	mkdir -p $PWD/efs
	EFS_FILESYSTEM=$(aws cloudformation describe-stack-resource --stack-name ecsagent-cli-$CLUSTER --logical-resource-id FileSystem|jq -r .StackResourceDetail.PhysicalResourceId)
	EFS_MOUNTTARGET_IP=$(aws efs describe-mount-targets --file-system-id $EFS_FILESYSTEM|jq -r .MountTargets[0].IpAddress)
	mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $EFS_MOUNTTARGET_IP:/ $PWD/efs
	mkdir -p $PWD/efs/etc/gmi/local
	cp *.conf $PWD/efs/etc/gmi/local/
	umount $PWD/efs
fi

SERVICE_JSON=`aws ecs describe-services --cluster=$CLUSTER --services $SERVICE_NAME`
SERVICE_EXISTS=`echo $SERVICE_JSON |jq -r ".services[].serviceName==\"$SERVICE_NAME\" and .services[].status==\"ACTIVE\""`
if [ "$SERVICE_EXISTS" != "true" ]; then
	ecs-cli compose create
	aws ecs create-service --cli-input-json "`cat $1`"
	ecs-cli compose service create
fi

SERVICE_DESIREDCOUNT=$(jq -r .desiredCount <$1)
if [ $SERVICE_DESIREDCOUNT -gt 0 ]; then
	ecs-cli compose service up
fi
ecs-cli compose service scale $SERVICE_DESIREDCOUNT

