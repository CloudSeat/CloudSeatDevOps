#!/bin/bash

# aws-cloudformation-stack-ensure.sh

PATH=/usr/local/gmi:$PATH

command -v aws >/dev/null 2>&1 || { echo "We require awscli but it's not installed.  Aborting." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "We require jq but it's not installed.  Aborting." >&2; exit 1; }

set -x

[ -z "$1" ] && { echo "DONNER WETTER. Usage: \n$0 CF_STACK_NAME CF_TEMPLATE_JSON CF_PARAMETERS_JSON\nPlease specify aws cloudformation stack name json template."; exit 1; }
CF_STACK_NAME=$1

[ -z "$2" ] && { echo "DONNER WETTER. Usage: \n$0 CF_STACK_NAME CF_TEMPLATE_JSON CF_PARAMETERS_JSON\nPlease specify aws cloudformation stack name json template."; exit 1; }
CF_TEMPLATE_JSON=$2

[ -z "$3" ] && { echo "DONNER WETTER. Usage: \n$0 CF_STACK_NAME CF_TEMPLATE_JSON CF_PARAMETERS_JSON\nPlease specify aws cloudformation stack name json template."; exit 1; }
CF_PARAMETERS_JSON=$3

if ! aws cloudformation describe-stacks --stack-name $CF_STACK_NAME; then
  if [[ -f $CF_TEMPLATE_JSON.init ]]; then
    # ability yo do a two stage template creation to work around multi vpc limitation
    aws cloudformation create-stack --stack-name $CF_STACK_NAME\
      --template-body "`cat $CF_TEMPLATE_JSON.init`"\
      --capabilities CAPABILITY_IAM\
      --parameters "`cat $CF_PARAMETERS_JSON`"
    aws cloudformation wait stack-create-complete --stack-name $CF_STACK_NAME
    aws cloudformation update-stack --stack-name $CF_STACK_NAME\
      --template-body "`cat $CF_TEMPLATE_JSON`"\
      --capabilities CAPABILITY_IAM\
      --parameters "`cat $CF_PARAMETERS_JSON`"
    aws cloudformation wait stack-update-complete --stack-name $CF_STACK_NAME
    SUCCESS=$?
  else
    aws cloudformation create-stack --stack-name $CF_STACK_NAME\
      --template-body "`cat $CF_TEMPLATE_JSON`"\
      --capabilities CAPABILITY_IAM\
      --parameters "`cat $CF_PARAMETERS_JSON`"
    aws cloudformation wait stack-create-complete --stack-name $CF_STACK_NAME
    SUCCESS=$?
  fi
else
  aws cloudformation get-template --stack-name $CF_STACK_NAME |jq -S .TemplateBody >/tmp/cf.stack.$CF_STACK_NAME.aws.template.json
  jq -S . <$CF_TEMPLATE_JSON >/tmp/cf.stack.$CF_STACK_NAME.local.template.json
  aws cloudformation describe-stacks --stack-name $CF_STACK_NAME| jq -r '.Stacks[0].Parameters[]| .ParameterKey + "=" + .ParameterValue'|sort >/tmp/cf.stack.$CF_STACK_NAME.aws.parameters.env
  jq -r '.[]|.ParameterKey + "=" + .ParameterValue' <$CF_PARAMETERS_JSON|sort >/tmp/cf.stack.$CF_STACK_NAME.local.parameters.env

  if ! { diff /tmp/cf.stack.$CF_STACK_NAME.local.template.json /tmp/cf.stack.$CF_STACK_NAME.aws.template.json \
    && diff /tmp/cf.stack.$CF_STACK_NAME.local.parameters.env /tmp/cf.stack.$CF_STACK_NAME.aws.parameters.env; } then
    aws cloudformation update-stack --stack-name $CF_STACK_NAME\
      --template-body "`cat $CF_TEMPLATE_JSON`"\
      --capabilities CAPABILITY_IAM\
      --parameters "`cat $CF_PARAMETERS_JSON`"
    aws cloudformation wait stack-update-complete --stack-name $CF_STACK_NAME
    SUCCESS=$?
  else
    echo "Not different"
    SUCCESS=$?
  fi
fi
aws cloudformation describe-stack-resources --stack-name $CF_STACK_NAME |tee /etc/gmi/cf.stack.$CF_STACK_NAME.resources.json
exit $SUCCESS