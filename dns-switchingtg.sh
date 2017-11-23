#!/bin/bash


_data=$1
_zone_id=
_active_json=/tmp/active.json
_standby_json=/tmp/standby.json
_hosted-zone-id=
_SetIdentifier_active=
_SetIdentifier_standby=

active_s=`aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/${_hosted-zone-id} | jq -r '.ResourceRecordSets[] | select(.SetIdentifier == "${_SetIdentifier_active}")' | jq '.Weight'`
standby_s=`aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/${_hosted-zone-id} | jq -r '.ResourceRecordSets[] | select(.SetIdentifier == "${_SetIdentifier_standby}")' | jq '.Weight'`

WeightStatus ()
{
aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/${_hosted-zone-id} | jq -r '.ResourceRecordSets[] | select(.SetIdentifier == "${_SetIdentifier_active}")'
aws route53 list-resource-record-sets --hosted-zone-id /hostedzone/${_hosted-zone-id} | jq -r '.ResourceRecordSets[] | select(.SetIdentifier == "${_SetIdentifier_standby}")'
}

_status=`eval echo '$'$1_s`

case ${_data} in
    "status")
        WeightStatus
        exit
        ;;
    "active")
        standby_w=0
        active_w=1
        ;;
    "standby")
        standby_w=1
        active_w=0
        ;;
    *)
        echo "select active/standby"
        exit
esac

cat << EOF > ${_active_json}
{
 "Changes": [
  {
   "Action": "UPSERT",
   "ResourceRecordSet": {
    "Name": "hogehoge.jp.",
    "Type": "A",
    "SetIdentifier": "hogehoge-active",
    "Weight": ${active_w},
    "TTL": 10,
    "ResourceRecords": [
     {
      "Value": "xxx.xxx.xxx.xxx"
     }
    ]
   }
  }
 ]
}
EOF

cat << EOF > ${_standby_json}
{
 "Changes": [
  {
   "Action": "UPSERT",
   "ResourceRecordSet": {
    "Name": "hogehoge.jp.",
    "Type": "A",
    "SetIdentifier": "hogehoge-standby",
    "Weight": ${standby_w},
    "TTL": 10,
    "ResourceRecords": [
     {
      "Value": "xxx.xxx.xxx.xxx"
     }
    ]
   }
  }
 ]
}
EOF

if [ 1 -eq ${_status} ]; then
  echo "[$0] This layer is already $1." 
  exit
fi
for _json in ${_active_json} ${_standby_json}
do
   aws route53 change-resource-record-sets --hosted-zone-id ${_zone_id} --change-batch file://${_json}
done

