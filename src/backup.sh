#!/bin/bash


source ./config.conf
servertobackup="$1"

backupfolder=/$installationfolder/backups
serverfolder=/$installationfolder/server

if [ ! -d "$backupfolder" ]; then
    mkdir $backupfolder
fi

if [ ! -d "$serverfolder/$servertobackup" ]; then
    echo "Server doesn't exist!"
else

    tar -czvf "$backupfolder/"$servertobackup"_$(date +\%Y-\%m-\%d_\%H:\%M).tar.gz" /$installationfolder/server/$servertobackup

fi
