#!/bin/bash

source ./config.conf

servername="$1"

folder="/$installationfolder/$servername"

if [ -d "/etc/systemd/system" ]; then
    rm /etc/systemd/system/$servername.service

    echo "[Unit]" >> /etc/systemd/system/$servername.service
    echo "Description=Startup" >> /etc/systemd/system/$servername.service
    echo "" >> /etc/systemd/system/$servername.service
    echo "[Service]" >> /etc/systemd/system/$servername.service
    echo "ExecStart=/$folder/start.sh" >> /etc/systemd/system/$servername.service
    echo "" >> /etc/systemd/system/$servername.service
    echo "[Install]" >> /etc/systemd/system/$servername.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/$servername.service

    systemctl daemon-reload
    systemctl enable $servername.service
    systemctl start $servername.service
else
    echo "Autostart can't be enabled. Autostart is based on systemd. Are you using a supported Distro"
fi