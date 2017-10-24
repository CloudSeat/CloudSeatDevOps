#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametros: \n$0 repositorioNombre"; exit 1; }
repositorioNombre=$1

# Crear el repositorio
# Si no se encuentra el repositorio crearlo
if ! repoExistente=`aws ecr describe-repositories --repository-names $repositorioNombre 2>>/var/log/aws-entorno.log`; then
  repoJson=`aws ecr create-repository --repository-name $repositorioNombre 2>>/var/log/aws-entorno.log`
  repoUri=`echo $repoJson | jq -r ".repository.repositoryUri"`
else 
  repoUri=`echo $repoExistente | jq -r ".repositories[0].repositoryUri"`
fi

# Retornar la Uri del repositorio creado, vacio en caso de error
echo $repoUri
