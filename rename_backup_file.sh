#!/bin/bash
# Descripcion: Script para renombrar archivo de Backup. Si no existe 1 archivo, se envia un correo de notificacion
 
LanguageArray=(
"/di1/file1"
"/di1/file2"
"/di2/file1"
)

Logfile="/var/log/rename_fortinet_backups.log"
mailrecipient="email@gmail.com"
Errormessage=""

function renameFile() {
    local FILE_DIR=$1
    filepath=$(dirname $FILE_DIR)
    suffix=$(date +%Y%m%d%H%M%S)

    filename=$(basename -- "$FILE_DIR")
    extension="${filename##*.}"
    original_name="${filename%.*}"

    new_name="${original_name}_${suffix}.${extension}"

    #echo "${filepath}/${new_name}"
    /usr/bin/mv $FILE_DIR "${filepath}/${new_name}"
}
 
# Print array values in  lines
for file in ${LanguageArray[*]}; do
    if [[ -f "$file" ]];then
	renameFile $file
    else
	errorfile="[$(date +'%Y-%m-%d %H:%M:%S %z')]: Archivo no valido ($file)"

	echo "$errorfile" >> $Logfile
	Errormessage+="$errorfile\n"
    fi
done
 
# Send mail
header="Archivos renombrados correctamente\n\n"
subject="Renombrado de Archivos de Backup Fortinet"
if [ ! -z "$Errormessage" ]
then
    header="Los Siguientes errores ocurrieron al renombrar los archivos de backup\n\n"
fi
echo -e "$header$Errormessage" | mail -s "Renombrado de Archivos de Backup Fortinet" $mailrecipient
