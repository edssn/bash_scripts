#!/bin/bash

umbral=43200

for R in $(ps -eo uid,pid,etimes,args | grep unoconv | egrep -v "listener" | awk {'print $2";"$3'}); do
	PID=$(echo $R | awk -F';' {'print $1'})
	RUN=$(echo $R | awk -F';' {'print $2'})
#	echo -n "$PID - $RUN"
	if [ $RUN -ge $umbral ]; then
		echo -n "Matando proceso $PID corriendo por $RUN segundos (>$umbral) ";
		kill -9 $PID
		if [ $? -eq 0 ]; then
			echo "OK"
		else
			echo "ERROR"
		fi
	fi 
done
