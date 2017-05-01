#!/bin/bash

# awscli y docker son requeridos
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "No se encuentra el comando docker.  Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametros: \n$0 proyectoCarpeta repositorioUri version"; exit 1; }
[ -z "$2" ] && { echo "Parametros: \n$0 proyectoCarpeta repositorioUri version"; exit 1; }
[ -z "$3" ] && { echo "Parametros: \n$0 proyectoCarpeta repositorioUri version"; exit 1; }

proyectoCarpeta=$1
# Construir el tag usando el uri del repositorio y el número de versión
tag="$2:$3"

# Ir a la carpeta del proyecto, construir la imagen y pushear la imagen a aws
cd $1

docker build -t $tag .
loginCommand=`aws ecr get-login`
$loginCommand
echo "docker push $tag"
docker push $tag 



