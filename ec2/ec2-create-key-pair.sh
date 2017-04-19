#!/bin/bash

# Requirement : awscli
command -v aws >/dev/null 2>&1 || { echo "We require awscli but it's noti installed.  Aborting." >&2; exit 1; }

[ -z "$1" ] && { echo "Please specify the key pair name"; exit 1; }

# Run the instances needed
keyPairResult=`aws ec2 create-key-pair --key-name $1`
echo $keyPairResult
echo $keyPairResult | jq -r ".KeyMaterial" > keyPair.pem

