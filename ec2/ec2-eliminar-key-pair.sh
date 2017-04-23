#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametro: \n$0 keyPairNombre"; exit 1; }
keyPairNombre=$1

# Eliminar el key pair
aws ec2 delete-key-pair --key-name $keyPairNombre

