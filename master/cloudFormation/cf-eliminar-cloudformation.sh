#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametro: \n$0 cfStackNombre"; exit 1; }
cfStackNombre=$1

echo "Eliminando stack"
# Eliminar el key pair
aws cloudformation delete-stack --stack-name $cfStackNombre
# Esperar a que se terminé de borrar el stack
aws cloudformation wait stack-delete-complete --stack-name $cfStackNombre
echo "Cloudformation stack eliminado correctamente"

#stackStatus="DELETE_IN_PROGRESS"
#while (stackStatus=="DELETE_IN_PROGRESS")
#do
#  stackStatus="DELETED"
#  stackDescribe=`aws cloudformation describe-stacks --stack-name $cfStackNombre`
#  stackStatus=`echo $stackDescribe | jq -r ".Stacks[].StackStatus"`
#done



