#!/bin/bash

source ./config.conf

servername="$1"
memorysize="$2"
mcversion="$3"

folder="/$installationfolder/cli-minecraftserver-manager/server/$servername"

if [ -d "/etc/systemd/system" ]; then
    rm /etc/systemd/system/$servername.service

    cat <<EOF > /etc/systemd/system/$servername.service
[Unit]
Description=cli-minecraftserver-manager autostart
After=network.target

[Service]
User=climinecraftservermanager
WorkingDirectory=/$folder
ExecStart=/usr/bin/java -Xms$memorysize -Xmx$memorysize -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:MaxGCPauseMillis=50 -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineSize=128 -XX:+OptimizeStringConcat -XX:+DisableExplicitGC -XX:ParallelGCThreads=4 -XX:ConcGCThreads=2 -XX:InitiatingHeapOccupancyPercent=15 -XX:+PerfDisableSharedMem -Dusing.aikars.flags=true -Dfile.encoding=UTF-8 -jar server_$mcversion.jar nogui
ExecStop=/bin/kill $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
else
    echo "Autostart can't be enabled. Autostart is based on systemd. Are you using a supported Distro?"
fi
