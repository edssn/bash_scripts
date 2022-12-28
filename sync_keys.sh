#!/bin/bash
# Tarea #1 
# Autor: Edisson Sigua
# Descripcion: Script que permite sincronizar el archivo authorized_keys en servidores remotos. 
#              Para configurar un nuevo servidor, copiar la clave publica del servidor origen en 
#              el usuario root del servidor remoto y crear un archivo dentro del directorio IPS_DIR
#              del servidor origen, el cua contendra la direccion ip del servidor remoto. 

LOCAL_KEYS_FILE="/root/keys/cedia_keys"
REMOTE_KEYS_FILE="/root/.ssh/authorized_keys"
IPS_DIR="/root/ips/"
SERVER_USER="root"
LOG_FILE="/var/log/sync_keys.log"
ERROR_COUNT=0


if [ ! -f $LOCAL_KEYS_FILE ];then
	echo "File '$LOCAL_KEYS_FILE' with the public keys does not exist"
	exit 1
fi

if [ ! -d $IPS_DIR ];then
	echo "Directory '$IPS_DIR' with the server configuration files does not exist"
	exit 1
fi

# Logging start process
echo "[$(date +'%d/%b/%Y %H:%M:%S %z')] START SYNC" >> $LOG_FILE
echo "Synchronizing..."

for FILE in $(find $IPS_DIR -type f -exec readlink -f {} \;)
do
	if [ -f $FILE ];then
		for LINE in $(cat $FILE)
		do
			# If file have header skip first iteration
			IP=$(echo $LINE | awk -F':' '{print $1}' | tr '[:upper:]' '[:lower:]')
			if [ "$IP" == "ip" ] || [[ $IP =~ ^#.*|^//.* ]];then continue; fi
			
			# Sync ssh public key file
			RESULT=$(rsync -aHPe "ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=3" $LOCAL_KEYS_FILE $SERVER_USER@$IP:$REMOTE_KEYS_FILE 2>&1)
			
			# Logging errors
			if [ $? -ne 0 ];then
				echo "[$(date +'%d/%b/%Y %H:%M:%S %z')] '$IP' ($FILE)" >> $LOG_FILE
				echo "ERROR:" >> $LOG_FILE
				echo "$RESULT" >> $LOG_FILE
				echo " " >> $LOG_FILE
				ERROR_COUNT=$((ERROR_COUNT+1))
			fi
		done
	else
		echo "File $FILE does not exist"
		echo "[$(date +'%d/%b/%Y %H:%M:%S %z')] Cannot access $FILE" >> $LOG_FILE
		echo " " >> $LOG_FILE
	fi
done

# Logging complete process
echo "[$(date +'%d/%b/%Y %H:%M:%S %z')] SYNC COMPLETE" >> $LOG_FILE

# If there is errors
if [ $ERROR_COUNT -gt 0 ];then
	echo "Done with $ERROR_COUNT errors. See $LOG_FILE"
else
	echo "Done without errors"
fi

exit 0
