#!/bin/bash

[ -z "$1" ] && { echo "Parametros: \n$0 repoNombre entornoNombre cfTemplateJson cfTemplateParams elbJson servicioJson proyectoCarpeta proyectoVersion"; exit 1; }
[ -z "$2" ] && { echo "Parametros: \n$0 repoNombre entornoNombre cfTemplateJson cfTemplateParams elbJson servicioJson proyectoCarpeta proyectoVersion"; exit 1; }
[ -z "$3" ] && { echo "Parametros: \n$0 repoNombre entornoNombre cfTemplateJson cfTemplateParams elbJson servicioJson proyectoCarpeta proyectoVersion"; exit 1; }
[ -z "$4" ] && { echo "Parametros: \n$0 repoNombre entornoNombre cfTemplateJson cfTemplateParams elbJson servicioJson proyectoCarpeta proyectoVersion"; exit 1; }
[ -z "$5" ] && { echo "Parametros: \n$0 repoNombre entornoNombre cfTemplateJson cfTemplateParams elbJson servicioJson proyectoCarpeta proyectoVersion"; exit 1; }
[ -z "$6" ] && { echo "Parametros: \n$0 repoNombre entornoNombre cfTemplateJson cfTemplateParams elbJson servicioJson proyectoCarpeta proyectoVersion"; exit 1; }
[ -z "$7" ] && { echo "Parametros: \n$0 repoNombre entornoNombre cfTemplateJson cfTemplateParams elbJson servicioJson proyectoCarpeta proyectoVersion"; exit 1; }
[ -z "$8" ] && { echo "Parametros: \n$0 repoNombre entornoNombre cfTemplateJson cfTemplateParams elbJson servicioJson proyectoCarpeta proyectoVersion"; exit 1; }

repoNombre=$1
entornoNombre=$2
cfTemplateJson=$3
cfTemplateParams=$4
elbJson=$5
servicioJson=$6
proyectoCarpeta=$7
proyectoVersion=$8

echo "$(date +'%d/%m/%Y %H:%M:%S') - Creando Repositorio con nombre $repoNombre"
repoUri=`./ecr/ecr-crear-repositorio.sh $repoNombre`
# Validamos que el repositorio se haya creado correctamente
[ -z $repoUri ] && {
  echo "$(date +'%d/%m/%Y %H:%M:%S') - No se pudo crear repositorio con nombre $repoNombre"
  exit
}
echo "$(date +'%d/%m/%Y %H:%M:%S') - Repositorio creado correctamente"

echo "$(date +'%d/%m/%Y %H:%M:%S') - Creando cluster con nombre $entornoNombre"
clusterSuccess=`./ecr/ecr-crear-cluster.sh $entornoNombre`
# Validamos que el cluster se haya creado correctamente
if [[ $clusterSuccess > 0 ]]; then
  echo "$(date +'%d/%m/%Y %H:%M:%S') - No se pudo crear cluster con nombre $entornoNombre"
  exit
fi
echo "$(date +'%d/%m/%Y %H:%M:%S') - Cluster creado correctamente"

echo "$(date +'%d/%m/%Y %H:%M:%S') - Creando keypair con nombre $entornoNombre"
keypairSuccess=`./ec2/ec2-crear-key-pair.sh $entornoNombre`
# Validamos que el keypair se haya creado correctamente
if [[ $keypairSuccess > 0 ]]; then
   echo "$(date +'%d/%m/%Y %H:%M:%S') - No se pudo crear keypair con nombre $entornoNombre"
   exit
fi
echo "$(date +'%d/%m/%Y %H:%M:%S') - Keypair creado correctamente"

echo "$(date +'%d/%m/%Y %H:%M:%S') - Creando Cloudformation stack con nombre $entornoNombre"
stackOutput=`./cloudFormation/cf-crear-cloudformation.sh $entornoNombre $cfTemplateJson $cfTemplateParams`
# Validamos que el stack se haya creado correctamente y obtenemos los ouput values
[ -z $stackOutput ] && {
   echo "$(date +'%d/%m/%Y %H:%M:%S') - No se pudo crear stack con nombre $entornoNombre"
   exit
}
echo "$(date +'%d/%m/%Y %H:%M:%S') - Cloudformation stack creado correctamente"

echo "$(date +'%d/%m/%Y %H:%M:%S') - Creando ELB"
# Obtenemos los ids de la subnet y del security group para crear el ELB
securityGroupId=`echo $stackOutput | jq -r ".[0].OutputValue"`
subnetId=`echo $stackOutput | jq -r ".[1].OutputValue"`
elbSuccess=`./ec2/ec2-crear-elb.sh $elbJson $securityGroupId $subnetId`
echo "$(date +'%d/%m/%Y %H:%M:%S') - ELB creado correctamente"

echo "$(date +'%d/%m/%Y %H:%M:%S') - Compilando proyecto $proyectoCarpeta"
./docker/docker-build-push.sh $proyectoCarpeta $repoUri $proyectoVersion
echo "$(date +'%d/%m/%Y %H:%M:%S') - Proyecto compilado correctamente y pusheado al repositorio $repoUri"

echo "$(date +'%d/%m/%Y %H:%M:%S') - Creando servicio"
cd ecr/
./ecr-crear-servicio.sh $servicioJson $entornoNombre
