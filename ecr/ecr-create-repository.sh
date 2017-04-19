#!/bin/bash

# Requirement : awscli
command -v aws >/dev/null 2>&1 || { echo "We require awscli but it's noti installed.  Aborting." >&2; exit 1; }

[ -z "$1" ] && { echo "Please specify a team"; exit 1; }
[ -z "$2" ] && { echo "Please specify a repository name"; exit 1; }

# Create the repository
repoJson=`aws ecr create-repository --repository-name $1/$2`
repoUri=`echo $repoUri |jq -r ".repository.repositoryUri"`
echo $repoJson
