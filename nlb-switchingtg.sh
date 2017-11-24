#!/bin/bash

# ============================= #
# Copyright © 2017 kohei YAMADA
# ============================= #

_region=ap-northeast-1

#listner_arn
_listner_arn=

#target-group-arn
blue=
green=


RuleStatus ()
{
  aws --region ${_region} elbv2 describe-rules --listener-arn ${_listner_arn} | jq '.Rules[] | select(.Priority == "default")'
}

SwitchTarget ()
{
  _data=`eval echo '$'$1`
  aws --region ${_region} elbv2 modify-listener --listener-arn ${_listner_arn} --port 43118 --protocol TCP --default-actions Type=forward,TargetGroupArn=${_data}
}



case $1 in
  status)
    RuleStatus
    ;;
  blue|green)
    RuleStatus | jq '.Actions[]' | grep $1
    if [ 0 -eq $? ]; then
     echo "This layer is already $1." 
     exit
    fi
    SwitchTarget $1
    ;;
  *)
    echo "select status/blue/green"
    exit
esac

