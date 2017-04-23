#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametro: \n$0 keyPairNombre keyPairArchivo"; exit 1; }
[ -z "$2" ] && { echo "Parametro: \n$0 keyPairNombre keyPairArchivo"; exit 1; }
keyPairNombre=$1
keyPairArchivo=$2

# Crear el key pair y guardarlo en archivo pem
resultado=`aws ec2 create-key-pair --key-name $keyPairNombre`
echo $resultado | jq -r ".KeyMaterial" > $keyPairArchivo

