#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametro: \n$0 cfStackNombre"; exit 1; }
cfStackNombre=$1

echo "$(date +'%d/%m/%Y %H:%M:%S') - Eliminando stack con nombre %stackNombre"
# Eliminar el key pair
aws cloudformation delete-stack --stack-name $cfStackNombre
# Esperar a que se terminé de borrar el stack
aws cloudformation wait stack-delete-complete --stack-name $cfStackNombre
echo "$(date +'%d/%m/%Y %H:%M:%S') - Cloudformation stack eliminado correctamente"

