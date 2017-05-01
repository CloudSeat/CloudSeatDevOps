#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametro: \n$0 keyPairNombre"; exit 1; }
keyPairNombre=$1

# Crear el key pair y guardarlo en archivo pem
keypair=`aws ec2 create-key-pair --key-name $keyPairNombre 2>>/var/log/aws-entorno.log`
keypairResultado=$?

# Si la creación fue exitosa, guardar la key en un archivo .pem para poder acceder a las instancias con ssh
if [[ "$keypairResultado" -eq "0" ]]; then
  echo $keypair | jq -r ".KeyMaterial" > "$keyPairNombre.pem"
fi

# Retornar el estado de la última llamada
echo $keypairResultado
