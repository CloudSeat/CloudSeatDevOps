#!/bin/bash

# awscli, ecscli y jq son requeridos
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }
command -v ecs-cli >/dev/null 2>&1 || { echo "No se encuentra el comando ecs-cli.  Abortando" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "No se encuentra el comando jq. Abortando" >&2; exit 1; }

set -x

[ -z "$1" ] && { echo "Parametros: \n$0 servicioJson servicioPrefijo"; exit 1; }
[ -z "$2" ] && { echo "Parametros: \n$0 servicioJson servicioPrefijo"; exit 1; }
servicioJson=$1
servicioPrefijo=$2

[ -f docker-compose.yml ] || { echo "No se encuentra el archivo docker-compose.yml o docker-compose.noversion.yml. Abortando"; exit 1; }

ECR_SERVICIO_NOMBRE=$(jq -r .serviceName <$servicioJson)
ECR_CLUSTER=$(jq -r .ECR_CLUSTER <$servicioJson)

ecs-cli configure --region us-west-2 --ECR_CLUSTER ECR_CLUSTER --compose-project-name-prefix $servicioPrefijo- --compose-service-name-prefix ${servicioPrefijo}- --cfn-stack-name-prefix ecsagent-cli-

ECR_SERVICIO_JSON=`aws ecs describe-services --ECR_CLUSTER=$ECR_CLUSTER --services $ECR_SERVICIO_NOMBRE`
ECR_SERVICIO_EXISTE=`echo $ECR_SERVICIO_JSON |jq -r ".services[].serviceName==\"$ECR_SERVICIO_NOMBRE\" and .services[].status==\"ACTIVE\""`
if [ "$ECR_SERVICIO_EXISTE" != "true" ]; then
  echo "Creando servicio"
  ecs-cli compose create
  aws ecs create-service --cli-input-json "`cat $servicioJson`"
	ecs-cli compose service create
fi

# Escalando el servicio al número de tareas deseadas
ECR_SERVICIO_NUMERO_TAREAS=$(jq -r .desiredCount <$servicioJson)
if [ $ECR_SERVICIO_NUMERO_TAREAS -gt 0 ]; then
	ecs-cli compose service up
fi
ecs-cli compose service scale $ECR_SERVICIO_NUMERO_TAREAS

