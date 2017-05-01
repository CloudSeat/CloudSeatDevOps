#!/bin/bash

# awscli y jq son requeridos
command -v aws >/dev/null 2>&1 || { echo "No se encuentra el comando aws.  Abortando" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "No se encuentra el comando jq. Abortando" >&2; exit 1; }

[ -z "$1" ] && { echo "Parametros: \n$0 stackNombre templateJson parametrosJson"; exit 1; }
[ -z "$2" ] && { echo "Parametros: \n$0 stackNombre templateJson parametrosJson"; exit 1; }
[ -z "$3" ] && { echo "Parametros: \n$0 stackNombre templateJson parametrosJson"; exit 1; }

stackNombre=$1
templateJson=$2
parametrosJson=$3

tackStatus
if ! aws cloudformation describe-stacks --stack-name $stackNombre 2>>/var/log/aws-entorno.log; then
  aws cloudformation create-stack --stack-name $stackNombre\
    --template-body "`cat $templateJson`"\
    --capabilities CAPABILITY_IAM\
    --parameters "`cat $parametrosJson`"\
     >>/var/log/aws-entorno.log 2>&1
  aws cloudformation wait stack-create-complete --stack-name $stackNombre
else
  # Si existe, validar si hay diferencias entre el stack existent con los parametros del script
  aws cloudformation get-template --stack-name $stackNombre |jq -S .TemplateBody >/tmp/cf.stack.$stackNombre.aws.template.json
  jq -S . <$templateJson >/tmp/cf.stack.$stackNombre.local.template.json
  aws cloudformation describe-stacks --stack-name $stackNombre| jq -r '.Stacks[0].Parameters[]| .ParameterKey + "=" + .ParameterValue'|sort >/tmp/cf.stack.$stackNombre.aws.parameters.env
  jq -r '.[]|.ParameterKey + "=" + .ParameterValue' <$parametrosJson|sort >/tmp/cf.stack.$stackNombre.local.parameters.env

  if ! { diff /tmp/cf.stack.$stackNombre.local.template.json /tmp/cf.stack.$stackNombre.aws.template.json \
    && diff /tmp/cf.stack.$stackNombre.local.parameters.env /tmp/cf.stack.$stackNombre.aws.parameters.env; } then
    aws cloudformation update-stack --stack-name $stackNombre\
      --template-body "`cat $templateJson`"\
      --capabilities CAPABILITY_IAM\
      --parameters "`cat $parametrosJson`"
    aws cloudformation wait stack-update-complete --stack-name $stackNombre
  fi
fi
stackResultado=`aws cloudformation describe-stacks --stack-name $stackNombre`
stackOutput=`echo $stackResultado | jq -r ".Stacks[0].Outputs"`
echo $stackOutput
