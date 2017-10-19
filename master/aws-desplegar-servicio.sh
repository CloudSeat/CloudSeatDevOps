#!/bin/biash

parametros="Parametros: \n$0 repoUri entornoNombre servicioJson proyectoCarpeta proyectoVersion"

[ $# -lt 5 ] && { echo $parametros; exit 1; }

repoUri=$1
entornoNombre=$2
servicioJson=$3
proyectoCarpeta=$4
proyectoVersion=$5

echo "$(date +'%d/%m/%Y %H:%M:%S') - Compilando proyecto $proyectoCarpeta"
./docker/docker-build-push.sh $proyectoCarpeta $repoUri $proyectoVersion
echo "$(date +'%d/%m/%Y %H:%M:%S') - Proyecto compilado correctamente y pusheado al repositorio $repoUri"

echo "$(date +'%d/%m/%Y %H:%M:%S') - Creando servicio"
cd ecr/
./ecr-crear-servicio.sh $servicioJson $entornoNombre
