#!/bin/bash
#====[ datadog-shotgun.sh ]=============
# 
# Description: 
#  The following script collects passenger metrics to help troubleshoot
#  Shotgun behaviour.
#
#
# Author: Teddy Wong
# Date: 2015-08-15
# 
# Version: v0.1
#  
#====[ datadog-shotgun.sh ]=============
appname=`basename $0`
pid=$$
tmpfile=/tmp/${appname}.${pid}

trap "rm -f ${tmpfile}* ${testfile}" EXIT

# Make sure you replace the API and or APP key below with the ones for your account
api_key='*******'


hostname="`hostname`"

currenttime=$(date +%s)

/opt/ruby-1.9.3-p547/bin/passenger-status > ${tmpfile}
max_pool_size=`grep Max ${tmpfile} | awk '{ print $5 }'`
number_process=`grep Processes ${tmpfile} | awk '{ print $3 }'`
request_queue=`grep "Requests in queue" ${tmpfile} | awk '{ print $4 }'`

curl  -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
    [{\"metric\":\"rodeofx.shotgun.max_pool_size\",
        \"points\":[[$currenttime, ${max_pool_size}]],
        \"type\":\"gauge\",
        \"host\":\"${hostname}\",
        \"tags\":[\"environment:production\"]}
        ]
    }" \
"https://app.datadoghq.com/api/v1/series?api_key=${api_key}"

curl  -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
    [{\"metric\":\"rodeofx.shotgun.number_process\",
        \"points\":[[$currenttime, ${number_process}]],
        \"type\":\"gauge\",
        \"host\":\"${hostname}\",
        \"tags\":[\"environment:production\"]}
        ]
    }" \
"https://app.datadoghq.com/api/v1/series?api_key=${api_key}"

curl  -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
    [{\"metric\":\"rodeofx.shotgun.request_queue\",
        \"points\":[[$currenttime, ${request_queue}]],
        \"type\":\"gauge\",
        \"host\":\"${hostname}\",
        \"tags\":[\"environment:production\"]}
        ]
    }" \
"https://app.datadoghq.com/api/v1/series?api_key=${api_key}"
