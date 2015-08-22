#!/bin/bash

#### VARIABLES
################################
appname=`basename $0`
pid=$$
tmpfile=/tmp/${appname}.${pid}
api_key='*****'
hostname="`hostname`"
currenttime=$(date +%s)

#### SUB ROUTINES
################################
datadog_send ()
{
    _metric=$1
    _host=$2
    _timestamp=$3
    _point_value=$4

    curl  -X POST -H "Content-type: application/json" \
    -d "{ \"series\" :
        [{\"metric\":\"${_metric}\",
            \"points\":[[${_timestamp}, ${_point_value}]],
            \"type\":\"gauge\",
            \"host\":\"${_host}\",
            \"tags\":[\"environment:production\"]}
            ]
        }" \
    "https://app.datadoghq.com/api/v1/series?api_key=${api_key}"
}

trap "rm -f ${tmpfile}* ${testfile}" EXIT

#### MAIN SCRIPT
################################
/opt/ruby-1.9.3-p547/bin/passenger-status > ${tmpfile}
max_pool_size=`grep Max ${tmpfile} | awk '{ print $5 }'``

datadog_send "rodeofx.shotgun.number_process" "${hostname}" "${currenttime}" "${max_pool_size}"
