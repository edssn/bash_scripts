#!/bin/bash
# Autor: Edisson Sigua
# Descripcion: Script para reiniciar el servicio de Redis si se detiene.

LOG_FILE="/var/log/redis-check.log"
SCRIPT_DATE=$(date +'%d/%b/%Y %H:%M:%S %z')

REDIS_PROCESS=$(/usr/bin/ps -aux | grep redis-server | grep -cv grep)
if [ $REDIS_PROCESS -eq 0 ];then 
    /usr/bin/systemctl start redis
    #echo "Starting Redis"
    echo "[$SCRIPT_DATE] - Starting Redis..." >> $LOG_FILE
else
    #echo "Redis aleady running"
    echo "[$SCRIPT_DATE] - Redis aleady running" >> $LOG_FILE
fi
