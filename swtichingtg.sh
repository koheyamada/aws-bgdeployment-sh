#!/bin/bash

_script_path=./

case $1 in
  alb)
    echo "[ApplicationLoadBalancer]--------------------------"
    ${_script_path}/alb-switchingtg.sh $2
    ;;
  nlb)
    echo "[NetworkLoadBalancer]--------------------------"
    ${_script_path}/nlb-switchingtg.sh $2
    ;;
  dns)
    echo "[DNS]--------------------------"
    ${_script_path}/dns-switchingtg.sh $2
    ;;
  *)
    echo "select alb/nlb/dns" 
    exit
esac

