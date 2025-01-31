#!/bin/bash

source ./config.conf

servername="$1"

folder="/$installationfolder/cli-minecraftserver-manager/server/$servername"

if [ -d "/etc/systemd/system" ]; then
    rm /etc/systemd/system/$servername.service

    cat <<EOF > /etc/systemd/system/$servername.service
[Unit]
Description=cli-minecraftserver-manager autostart

[Service]
User=climinecraftservermanager
ExecStart=$folder/start.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable $servername.service
    systemctl start $servername.service
else
    echo "Autostart can't be enabled. Autostart is based on systemd. Are you using a supported Distro?"
fi
