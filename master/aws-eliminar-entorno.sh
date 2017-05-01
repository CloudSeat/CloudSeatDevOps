#!/bin/bash

[ -z "$1" ] && { echo "Parametros: \n$0 repoNombre entornoNombre elbNombre servicioNombre"; exit 1; }
[ -z "$2" ] && { echo "Parametros: \n$0 repoNombre entornoNombre elbNombre servicioNombre"; exit 1; }
[ -z "$3" ] && { echo "Parametros: \n$0 repoNombre entornoNombre elbNombre servicioNombre"; exit 1; }
[ -z "$4" ] && { echo "Parametros: \n$0 repoNombre entornoNombre elbNombre servicioNombre"; exit 1; }

repoNombre=$1
entornoNombre=$2
elbNombre=$3
servicioNombre=$4

./ecr/ecr-eliminar-repositorio.sh $repoNombre
./ecr/ecr-eliminar-cluster.sh $entornoNombre
./ec2/ec2-eliminar-key-pair.sh $entornoNombre
./cloudFormation/cf-eliminar-cloudformation.sh $entornoNombre
./ec2/ec2-eliminar-elb.sh $elbNombre
./ecr/ecr-eliminar-servicio.sh $servicioNombre $entornoNombre

