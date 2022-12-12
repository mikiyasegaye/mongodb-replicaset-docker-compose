#!/bin/bash

echo "================================="
echo "     initiating replicaset       "
echo "================================="

mongoOne=$1
mongoTwo=$2
mongoThree=$3
replicaSet=$4

while :; do
    mongoOneStatus=$(mongo --host $mongoOne --port 27017 --eval "db.hello().ok" | tail -n1 | grep -E '(^|\s)1($|\s)')
    mongoTwoStatus=$(mongo --host $mongoTwo --port 27017 --eval "db.hello().ok" | tail -n1 | grep -E '(^|\s)1($|\s)')
    mongoThreeStatus=$(mongo --host $mongoThree --port 27017 --eval "db.hello().ok" | tail -n1 | grep -E '(^|\s)1($|\s)')
    if [[ $mongoOneStatus == 1 ]] && [[ $mongoTwoStatus == 1 ]] && [[ $mongoThreeStatus == 1 ]]; then
        replicaSetInitConfg="rs.initiate({_id : '$replicaSet',members: [{ _id: 0, host: '$mongoOne' },{ _id: 1, host: '$mongoTwo' },{ _id: 2, host: '$mongoThree' }]});"
        mongo mongodb://$mongoOne --eval "$replicaSetInitConfg"
        break
    else
        echo "***   replicaset members not ready yet. rechecking in 5 seconds   ***"
        sleep 5
    fi
done
