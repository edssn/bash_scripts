#!/bin/bash
# Autor: Edisson Sigua <edisson.sigua@cedia.org.ec>
# Descripcion: Script para actualizar una plataforma Moodle
#		Se debe especificar el directorio de Moodle, la url para  
#		descargar el nuevo codigo de moodle y la localizacion del 
#		archivo binario de php como variables globales
#
#		Junto a este script, debe estar un script de php con nombre 
#		get_moodle_plugins.php, el cual obtiene los plugins externos
#		instalados en Moodle y el archivo de configuracion de Moodle 
#		y los pasa al nuevo directorio de moodle.
#
#		Este script ha sido probado para migrar desde versiones Moodle 
#		3.8.x hasta 4.0.x

## Global variables
MOODLE_DIR="/var/www/moodle39/moodle"
NEW_MOODLE_URL="https://download.moodle.org/download.php/direct/stable39/moodle-3.9.18.tgz"
PHP_BIN="/usr/bin/php"


# Function to remove last character from string if last character is slash (/)
function removeSlashCharacter() {
    local text=$1
    last=$(echo "${text: -1}")
    [[ $last == "/" ]] && {
        text=$(echo ${text:0:-1})
    }
    echo $text
}


# Function to rollback changes
function rollbackChanges() {
    if [[ -d "$MOODLE_BACKUP_DIR" ]];then
	[[ -d $MOODLE_DIR ]] && {
            /usr/bin/rm -rf $MOODLE_DIR
        }
        /usr/bin/mv $MOODLE_BACKUP_DIR $MOODLE_DIR
    fi
}


# Backup Moodledata Subdir
function backupMoodledataSubdir() {
    local subdir=$1
    [[ -d "$MOODLE_DATA_DIR" && -d "$MOODLE_DATA_DIR/$subdir" ]] && {
    	[[ -d "$MOODLE_DATA_DIR/$subdir.backup" ]] && {
            /usr/bin/rm -rf $MOODLE_DATA_DIR/$subdir.backup
    	}
    	/usr/bin/mv $MOODLE_DATA_DIR/$subdir $MOODLE_DATA_DIR/$subdir.backup
    }
}




# Validations
[[ ! -d $MOODLE_DIR ]] && {
    echo "There is no exists Moodle directory ($MOODLE_DIR)"
    exit 1
}

[[ ! -f "$MOODLE_DIR/config.php" ]] && {
    echo "There is no exists Moodle config file ($MOODLE_DIR/config.php)"
    exit 1
}

[[ ! -f "$MOODLE_DIR/version.php" ]] && {
    echo "There is no exists Moodle version file ($MOODLE_DIR/version.php)"
    exit 1
}


## Get moodledata and moodle backup paths
MOODLE_DATA_DIR=$(cat "$MOODLE_DIR/config.php" | grep dataroot | awk -F"=" '{ print $2 }' | sed 's/[\x27\x22\x3B\x20\x09\x2B]//g')
MOODLE_VERSION=$(cat "$MOODLE_DIR/version.php" | grep '$release' | awk -F"=" '{ print $2 }' | awk -F" " '{ print $1 }' | sed 's/[\x27\x22\x3B\x20\x09\x2B]//g')
MOODLE_BACKUP_DIR="$MOODLE_DIR$MOODLE_VERSION.backup" 


# Validate moodle backup exist
[[ -d $MOODLE_BACKUP_DIR ]] && {
    echo "Directory of Moodle backup ($MOODLE_BACKUP_DIR) already exists"
    exit 1
}



# Remove last characters if it are slash
MOODLE_DIR=$( removeSlashCharacter $MOODLE_DIR )
MOODLE_BACKUP_DIR=$( removeSlashCharacter $MOODLE_BACKUP_DIR )
MOODLE_DATA_DIR=$( removeSlashCharacter $MOODLE_DATA_DIR )



echo "STEP 0: Set Moodle Site in Maintenance Mode..."
$PHP_BIN $MOODLE_DIR/admin/cli/maintenance.php --enable > /dev/null
echo "STEP 0: Done"



### ====================== STEP 1 ============================
echo "STEP 1: Getting list of Moodle third party plugins..."
EXTERNAL_PLUGINS_DIR=$($PHP_BIN get_moodle_plugins.php $MOODLE_DIR)
RESULT_CODE=$?
[[ $RESULT_CODE -eq 1 ]] && {
    echo "ERROR: Call to get_moodle_plugins.php script return error"
    echo "ERROR: Run '$PHP_BIN get_moodle_plugins.php $MOODLE_DIR' to see details"
    exit 1
}
echo "STEP 1: Done"



### ====================== STEP 2 ============================
echo "STEP 2: Downloading new Moodle code..."
MOODLE_NEW_FILE=download.tgz
wget -q -O $MOODLE_NEW_FILE $NEW_MOODLE_URL
RESULT_CODE=$?
[[ $RESULT_CODE -ne 0 ]] && {
    echo "STEP 2: Error downloading new Moodle code"
    exit 1
}
echo "STEP 2: Done"



### ====================== STEP 3 ============================
echo "STEP 3: Backing Moodle dir..."
if [[ -d "$MOODLE_DIR" && ! -d "$MOODLE_BACKUP_DIR" ]];then
    #/usr/bin/rsync -a $MOODLE_DIR ~/
    /usr/bin/mv $MOODLE_DIR/ $MOODLE_BACKUP_DIR/
fi
echo "STEP 3: Done"



### ====================== STEP 4 ============================
echo "STEP 4: Untarring new Moodle Code and Copying to Moodle dir..."
/usr/bin/tar -xf $MOODLE_NEW_FILE -C /tmp
/usr/bin/rsync -a /tmp/moodle/ $MOODLE_DIR/
/usr/bin/rm -f $MOODLE_NEW_FILE
/usr/bin/rm -rf /tmp/moodle
echo "STEP 4: Done"



### ====================== STEP 5 ============================
echo "STEP 5: Copying moodle external plugins to new Moodle dir"
for PLUGIN_DIR in $EXTERNAL_PLUGINS_DIR
do
    preff=$(echo $PLUGIN_DIR | awk -F "-" '{print $1}')
    suff=$(echo $PLUGIN_DIR | awk -F "-" '{print $2}')
    if [ -d "$MOODLE_BACKUP_DIR/$preff/$suff" ];then
        #echo "$MOODLE_BACKUP_DIR/$preff/$suff"
        #echo "$MOODLE_DIR/$preff/"
	echo "STEP 5: Copying plugin $preff"_"$suff"
        /usr/bin/cp -a "$MOODLE_BACKUP_DIR/$preff/$suff" "$MOODLE_DIR/$preff/"
    fi
done
echo "STEP 5: Done"



### ====================== STEP 6 ============================
echo "STEP 6: Copying config.php file..."
/usr/bin/cp -a "$MOODLE_BACKUP_DIR/config.php" "$MOODLE_DIR/config.php"
echo "STEP 6: Done"



### ====================== STEP 7 ============================
echo "STEP 7: Backing moodledata dirs..."
backupMoodledataSubdir cache
backupMoodledataSubdir localcache
backupMoodledataSubdir sessions
echo "STEP 7: Done"



### ====================== STEP 8 ============================
echo "STEP 8: Purging Moodle caches..."
$PHP_BIN $MOODLE_DIR/admin/cli/purge_caches.php
echo "STEP 8: Done"



# Finish
echo -e "\n"
echo "New moodle directory ready to upgrade"
echo "Before upgrade, please run the following commands"
echo "sudo chown -R root: $MOODLE_DIR"
echo "sudo find $MOODLE_DIR -type d -exec chmod 755 {} +"
echo "sudo find $MOODLE_DIR -type f -exec chmod 644 {} +"
echo -e "\n"
echo "Now, start upgrading with following command"
echo "sudo -u apache $PHP_BIN $MOODLE_DIR/admin/cli/upgrade.php"
echo -e "\n"
echo "Finally, don't forget"
echo "$PHP_BIN $MOODLE_DIR/admin/cli/maintenance.php --disable"
echo "/usr/bin/rm -rf $MOODLE_DATA_DIR/cache.backup $MOODLE_DATA_DIR/localcache.backup $MOODLE_DATA_DIR/sessions.backup"
echo "sudo chown -R apache: $MOODLE_DATA_DIR"
echo "sudo find $MOODLE_DATA_DIR -type d -not -path '$MOODLE_DATA_DIR/filedir/*' -exec chmod 750 {} +"
echo "sudo find $MOODLE_DATA_DIR -type f -not -path '$MOODLE_DATA_DIR/filedir/*' -exec chmod 640 {} +"
