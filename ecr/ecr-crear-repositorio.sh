#!/bin/bash

# awscli es requerido
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametros: \n$0 equipoNombre repositorioNombre"; exit 1; }
repositorioNombre=$1

# Crear el repositorio
repoJson=`aws ecr create-repository --repository-name $repositorioNombre`
repoUri=`echo $repoJson | jq -r ".repository.repositoryUri"`
echo $repoUri
