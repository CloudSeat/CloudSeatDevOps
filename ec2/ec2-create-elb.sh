#!/bin/bash

# requirement : awscli, jq
command -v aws >/dev/null 2>&1 || { echo "We require awscli but it's not installed.  Aborting." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "We require jq but it's not installed.  Aborting." >&2; exit 1; }

set -x

[ -z "$1" ] && { echo "Please specify aws elb input cli json filename."; exit 1; }

ELB_NAME=$(jq -r .LoadBalancerName <$1)

# check or create ELB
if ! ELB_JSON=`aws elb describe-load-balancers --load-balancer-names $ELB_NAME`; then
  echo "ELB $ELB_NAME does not exist, creating."
  aws elb create-load-balancer --cli-input-json "`cat $1`" || exit $?
fi
