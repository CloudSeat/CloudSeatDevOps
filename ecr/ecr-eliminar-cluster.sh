#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametros: \n$0 clusterNombre"; exit 1; }
clusterNombre=$1

# Eliminar el cluster
aws ecs delete-cluster --cluster $1
