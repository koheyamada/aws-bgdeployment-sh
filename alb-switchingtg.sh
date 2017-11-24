#!/bin/bash

# ============================= #
# Copyright © 2017 kohei YAMADA
# ============================= #


# Region Name
_region=ap-northeast-1

# Listner ARN
_listner_arn_80=
_listner_arn_443=

# Listner Rule ARN
_listner_rule_80=
_listner_rule_443=

# Target Group ARN
blue=
green=


# Setting Functions
RuleStatus ()
{
  aws --region ${_region} elbv2 describe-rules --listener-arn ${_listner_arn_80} | jq '.Rules[] | select(.Priority == "1")'
  aws --region ${_region} elbv2 describe-rules --listener-arn ${_listner_arn_443} | jq '.Rules[] | select(.Priority == "1")'
}

SwitchTarget ()
{
  _data=`eval echo '$'$1`
  aws --region ${_region} elbv2 modify-rule --rule-arn ${_listner_rule_80} --actions Type=forward,TargetGroupArn=${_data}
  aws --region ${_region} elbv2 modify-rule --rule-arn ${_listner_rule_443} --actions Type=forward,TargetGroupArn=${_data}
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

