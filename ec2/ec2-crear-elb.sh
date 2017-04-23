#!/bin/bash

# awscli y jq son requeridos
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "No se encuentra el comando jq. Abortando" >&2; exit 1; }

set -x

[ -z "$1" ] && { echo "Parametro: \n$0 elbJson"; exit 1; }

elbJson=$1
elbNombre=$(jq -r .LoadBalancerName <$elbJson)

# Si no se encuentra el balanceador de carga crearlo
if ! ELB_JSON=`aws elb describe-load-balancers --load-balancer-names $elbNombre`; then
  echo "ELB $elbNombre no existe, creando"
  aws elb create-load-balancer --cli-input-json "`cat $elbJson`" || exit $?
fi
