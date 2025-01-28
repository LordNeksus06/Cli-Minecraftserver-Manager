autostart() {                       # To enable autostart
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
        echo "Autostart can't be enabled are you using the right distro"
    fi
}