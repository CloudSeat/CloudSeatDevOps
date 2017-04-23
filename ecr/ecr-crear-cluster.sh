#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametros: \n$0 clusterNombre"; exit 1; }
clusterNombre=$1

# Crear el cluster
aws ecs create-cluster --cluster-name $clusterNombre
