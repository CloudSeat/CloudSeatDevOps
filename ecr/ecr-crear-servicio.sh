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

servicioNombre=$(jq -r .serviceName <$servicioJson)
cluster=$(jq -r .cluster <$servicioJson)

ecs-cli configure --region us-west-2 --ECR_CLUSTER cluster --compose-project-name-prefix $servicioPrefijo- --compose-service-name-prefix ${servicioPrefijo}- --cfn-stack-name-prefix ecsagent-cli-

servicio=`aws ecs describe-services --ECR_CLUSTER=$cluster --services $servicioNombre`
servicioExiste=`echo $servicio | jq -r ".services[].serviceName==\"$servicioNombre\" and .services[].status==\"ACTIVE\""`
if [ "$servicioExiste" != "true" ]; then
  echo "Creando servicio"
  ecs-cli compose create
  aws ecs create-service --cli-input-json "`cat $servicioJson`"
	ecs-cli compose service create
fi

# Escalando el servicio al número de tareas deseadas
numeroTareas=$(jq -r .desiredCount <$servicioJson)
if [ $numeroTareas -gt 0 ]; then
	ecs-cli compose service up
fi
ecs-cli compose service scale $numeroTareas

