#!/bin/bash

# Requirement : awscli
command -v aws >/dev/null 2>&1 || { echo "We require awscli but it's noti installed.  Aborting." >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "We require docker but it's noti installed.  Aborting." >&2; exit 1; }

[ -z "$1" ] && { echo "Please specify the location of the project to build"; exit 1; }
[ -z "$2" ] && { echo "Please specify a repository uri"; exit 1; }
[ -z "$3" ] && { echo "Please specify the build version"; exit 1; }

# Build the tag with the repo uri and the version number
tag="$2:dev-$3"

# Move to the project folder build the image, tag it, log in to aws and push it
cd $1

docker build -t $tag .
loginCommand=`aws ecr get-login`
$loginCommand
echo "docker push $tag"
docker push $tag 



