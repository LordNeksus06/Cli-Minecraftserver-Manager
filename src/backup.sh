#!/bin/bash


source ./config.conf
servertobackup="$1"

backupfolder=/$installationfolder/cli-minecraftserver-manager/backups
serverfolder=/$installationfolder/cli-minecraftserver-manager/server

# Erzeuge einen 4-stelligen Wert, wobei jedes Zeichen zufällig aus dem charset gewählt wird
random_value=$(cat /dev/urandom | tr -dc "$charset" | fold -w 4 | head -n 1)

if [ ! -d "$backupfolder" ]; then
    mkdir $backupfolder
fi

if [ ! -d "$serverfolder/$servertobackup" ]; then
    echo "Server doesn't exist!"
else

    cd /$installationfolder/cli-minecraftserver-manager/server
    tar -czvf "$backupfolder/"$servertobackup"_$(date +\%Y-\%m-\%d_\%H:\%M)_$random_value.tar.gz" $servertobackup
    cd

fi
