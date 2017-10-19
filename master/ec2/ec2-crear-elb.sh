#!/bin/bash

# awscli y jq son requeridos
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "No se encuentra el comando jq. Abortando" >&2; exit 1; }

[ $# -lt 4 ] && { echo "Parametro: \n$0 nombre elbJson securityGroupId subnetId"; exit 1; }

elbJson=$2
elbNombre=$1
securityGroupId=$3
subnetId=$4

# Si no se encuentra el balanceador de carga crearlo
if ! elbExistentes=`aws elb describe-load-balancers --load-balancer-names $elbNombre 2>>/var/log/aws-entorno.log`; then
  aws elb create-load-balancer --load-balancer-name $elbNombre --security-groups $securityGroupId --subnets $subnetId --cli-input-json "`cat $elbJson`" >>/var/log/aws-entorno.log 2>&1
  # Retornar el estado de la última llamada
  echo $?
else 
  # Retornar un mensaje de error, explicando que el elb ya existe
  echo 255 
fi
