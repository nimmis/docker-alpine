#!/bin/sh

BUILD=$1

CMD=$(docker run -d  $BUILD)


START_TIME=$SECONDS
ELAPSED_TIME=0

while [ $ELAPSED_TIME -lt 10 ] && [ "$RES" !=  "11" ] ;  do

  crond=$(docker exec $CMD supervisorctl status  2> /dev/null | grep crond | grep RUNNING| wc -l | sed 's/ //g')
  rsyslogd=$(docker exec $CMD supervisorctl status  2> /dev/null | grep rsyslogd | grep RUNNING| wc -l | sed 's/ //g')

  RES=$crond$rsyslogd
  ELAPSED_TIME=$(($SECONDS - $START_TIME))
  sleep 1

done


ret=$(docker rm -f $CMD)

if [ "$RES" !=  "11" ] ; then
  exit 1
fi
