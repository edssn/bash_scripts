#!/bin/bash
# Autor: Edisson Sigua
# Descripcion: Script para reiniciar el servicio de Redis si se detiene.

LOG_FILE="/var/log/redis-check.log"
SCRIPT_DATE=$(date +'%d/%b/%Y %H:%M:%S %z')

# Revisa el estado del servicio
/usr/bin/systemctl status redis &> /dev/null
# Si la salida del comando no es 0, el servicio está caído
if [ $? -ne 0 ]; then
    #echo -n "Redis caído, arrancando ..."
    echo "[$SCRIPT_DATE] - Redis caído, arrancando ..." >> $LOG_FILE
    /usr/bin/systemctl start redis &> /dev/null
    if [ $? -eq 0 ]; then
        #echo 'OK'
        echo "[$SCRIPT_DATE] - OK" >> $LOG_FILE
    else
        #echo 'ERROR'
        echo "[$SCRIPT_DATE] - ERROR" >> $LOG_FILE
        exit 1
    fi
fi

exit 0
