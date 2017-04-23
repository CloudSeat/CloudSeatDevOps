#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametros: \n$0 grupoSeguridadId subnetId instanciasNumero clusterNombre"; exit 1; }
[ -z "$2" ] && { echo "Parametros: \n$0 grupoSeguridadId subnetId instanciasNumero clusterNombre"; exit 1; }
[ -z "$3" ] && { echo "Parametros: \n$0 grupoSeguridadId subnetId instanciasNumero clusterNombre"; exit 1; }
[ -z "$4" ] && { echo "Parametros: \n$0 grupoSeguridadId subnetId instanciasNumero clusterNombre"; exit 1; }

grupoSeguridadId=$1
subnetId=$2
instanciasNumero=$3
clusterNombre=$4

# Inicias las instancas requeridas
aws ec2 run-instances --image-id ami-8ca83fec --count $instanciasNumero --instance-type t2.micro --security-group-ids $grupoSeguridadId --subnet-id $subnetId --associate-public-ip-address

# Crear el cluster
aws ecs create-cluster --cluster-name $clusterNombre


