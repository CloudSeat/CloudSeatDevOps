#!/bin/bash

# awscli y jq son requeridos
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "No se encuentra el comando jq. Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametro: \n$0 elbNombre"; exit 1; }
elbNombre=$1

# Si no se encuentra el balanceador de carga crearlo
aws elb delete-load-balancer --load-balancer-name $elbNombre|| exit $?
