#!/bin/bash

parametros="Parametros: \n$0 repoNombre entornoNombre elbNombre servicioNombre"

[ $# -lt 4  ] && { echo $parametros; exit 1; }

repoNombre=$1
entornoNombre=$2
elbNombre=$3
servicioNombre=$4

./ecr/ecr-eliminar-servicio.sh $servicioNombre $entornoNombre
./ec2/ec2-eliminar-elb.sh $elbNombre
./cloudFormation/cf-eliminar-cloudformation.sh $entornoNombre
./ecr/ecr-eliminar-repositorio.sh $repoNombre
./ecr/ecr-eliminar-cluster.sh $entornoNombre
./ec2/ec2-eliminar-key-pair.sh $entornoNombre
