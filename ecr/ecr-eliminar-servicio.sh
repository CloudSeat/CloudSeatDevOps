#!/bin/bash

# awscli y ecscli son requeridos
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }
command -v ecs-cli >/dev/null 2>&1 || { echo "No se encuentra el comando ecs-cli.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametros: \n$0 servicioNombre clusterNombre"; exit 1; }
[ -z "$2" ] && { echo "Parametros: \n$0 servicioNombre clusterNombre"; exit 1; }
servicioNombre=$1
clusterNombre=$2

ECR_SERVICIO_JSON=`aws ecs describe-services --cluster=$clusterNombre --services $servicioNombre`
ECR_SERVICIO_EXISTE=`echo $ECR_SERVICIO_JSON |jq -r ".services[].serviceName==\"$servicioNombre\""`
if [ "$ECR_SERVICIO_EXISTE" == "true" ]; then
  echo "Eliminando servicio"
  # Bajando el número de tareas del servicio a 0 antes de eliminarlo
  aws ecs update-service --cluster $clusterNombre --service $servicioNombre --desired-count 0
  aws ecs delete-service --cluster $clusterNombre --service $servicioNombre
else
  echo "El servicio no existe"
fi


