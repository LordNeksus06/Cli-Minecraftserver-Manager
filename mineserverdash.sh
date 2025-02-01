#!/bin/bash

show_help() {
    echo "Verwendung: $0 [OPTION]"
    echo ""
    echo "Optionen:"
    echo "  --install       Installiert das Programm"
    echo "  --uninstall     Deinstalliert das Programm"
    echo "  --help          Zeigt diese Hilfe an"
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Das Skript wird ohne root-Rechte ausgeführt. Bitte mit sudo ausführen!"
        exit 1
    fi
}

arguments() {
    get_arg() {
        [[ -n "$2" && "$2" != -* ]] && eval "$3='$2'" || { echo "$1 needs an argument."; exit 1; };
    }

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --memorysize|-m) get_arg "$1" "$2" memorysize; shift 2 ;;
            --servername) get_arg "$1" "$2" servername; shift 2 ;;
            --mcversion|-v) get_arg "$1" "$2" mcversion; shift 2 ;;
            --mctype) get_arg "$1" "$2" mctype; shift 2 ;;
            --autostart) autostart="true"; shift ;;
            --help|-h) show_help; exit ;;
            *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
        esac 
    done
}

install() {
    if [[ "$memorysize" == "" ]]; then
        memorysize="$default_memorysize"
    fi

    if [[ "$servername" == "" ]]; then
        read -p "You haven't specified a server name! Please select one: " servername
    fi

    if [[ "$mcversion" == "" ]]; then
        read -p "You haven't specified a minecraft version! Please select one (e.g. 1.20.1): " mcversion
    fi

    if [[ "$mctype" == "" ]]; then
        read -p "You haven't specified a type of minecraft! Please select one (e.g. vanilla, forge): " mctype
    fi

    bash ./src/installer.sh "$servername" "$mcversion" "$mctype"

    bash ./src/systemd.sh $servername "$memorysize" "$mcversion"
}

backup() {
    echo "Backup causes a server stop to prevent data corruption in the backup files. Do you want to start the Server after the Backup? (Y/n): " start_after_backup

    if [[ "$servername" == "" ]]; then
        echo "You haven't specified the server! Please select one of the following"
        echo "--------------------------------------------"
        
        ls /$installationfolder/cli-minecraftserver-manager/server

        echo "--------------------------------------------"

        read -p "Select the Server: " servername
    fi

    systemctl stop $servername.service

    bash ./src/backup.sh "$servername"

    if [[ "${antwort,,}" =~ ^(y|j)$ ]]; then
        systemctl start $servername
        echo "Server starts"
    fi
}

start_server() {
    if [[ "$servername" == "" ]]; then
        read -p "You haven't specified a server name! Please select one: " servername
    fi

    systemctl start $servername.service
}

remove_server() {

    read -p "Do you really want to remove the Server? (Y/n): " antwort

    if [[ "${antwort,,}" =~ ^(y|j)$ ]]; then
        if [[ "$servername" == "" ]]; then
            read -p "You haven't specified a server name! Please select one: " servername
        fi

        systemctl stop $servername.service
        systemctl disable $servername.service

        rm /etc/systemd/system/$servername.service
        rm -r /$installationfolder/cli-minecraftserver-manager/server/$servername
    else
        echo "Deletion stopped"
        exit 0
    fi

   
}

server_status() {

    total_load="0"

    IFS=$'\n' read -d '' -r -a server_array < <(find "/$installationfolder/cli-minecraftserver-manager/server" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

    echo ""
    echo "-----------------------------------------------"

    for server in "${server_array[@]}"; do

        status_server_status="$(systemctl is-active $server.service)"
        cpu_server_status=$(systemctl show -p MainPID --value $server.service)

        if [[ "$status_server_status" == "active" ]]; then
            cpu_usage="$(top -b -n 1 -p $cpu_server_status | tail -n +8 | head -n 1 | awk '{print $9}')"

            memory_usage_bytes="$(systemctl show -p MemoryCurrent --value $server)"
            memory_server_status=$(echo "scale=2; $memory_usage_bytes / 1024 / 1024" | bc)
        else
            memory_server_status=0
            cpu_usage="0.0"
        fi

        if [ "$status_server_status" == "active" ]; then
            color="\033[1;32m"  # Geen for "active"
        else
            color="\033[1;31m"  # Red for "inactive"
        fi

        echo -e "$server   $color$status_server_status\033[0m   CPU usage: $cpu_usage%  Memory: $memory_server_status MB"
        
        total_cpu_load=($total_load + $cpu_usage)
    done
    echo ""
    echo "Total load    CPU usage: $total_cpu_load"
    echo "-----------------------------------------------"
    echo ""
}

source ./config.conf

# ============== preperation ================

if [ "$password" == "" ]; then                                                                                     # Check the installationfolder
    random_value=$(cat /dev/urandom | tr -dc "$charset" | fold -w 12 | head -n 1)
    sed -i "s/^password=\".*\"$/password=\"$random_value\"/" config.conf
fi

if ! id "climinecraftservermanager" &>/dev/null; then
    check_root
    password_encrypted=$(openssl passwd -6 "$password")
    useradd -p "$password_encrypted" -s /bin/bash climinecraftservermanager
fi

if [ ! -d "$installationfolder" ]; then                                                                                     # Check the installationfolder
    echo "The installationfolder doesn't exist. Check /config.conf"
    exit 0
fi

if [ ! -d "$installationfolder/cli-minecraftserver-manager" ]; then                                                                                     # Check the installationfolder
    mkdir $installationfolder/cli-minecraftserver-manager
fi

if [ ! -d "$installationfolder/cli-minecraftserver-manager/server" ]; then                                                                                     # Check the installationfolder
    mkdir $installationfolder/cli-minecraftserver-manager/server
fi

if [ ! -d "$installationfolder/cli-minecraftserver-manager/backups" ]; then                                                                                     # Check the installationfolder
    mkdir $installationfolder/cli-minecraftserver-manager/backups
fi

if [ $# -eq 0 ]; then                                                                                                       # Check the command
    echo "You don't have specified an action. Use --help for more information"
    exit 1
fi

# ============== preperation finished ================

check_root

case "$1" in                                                                                                                # What is the first argument
    install) shift; arguments "$@"; install;;
    backup) systemd_configuration; shift;;
    start) start_server; shift;;
    remove) remove_server; shift;;
    status) server_status; shift;;
    *) echo "The Argument $1 doesn't exist"; show_help; exit 1;;
esac

# Autostart at installation

if [[ "$autostart" == "true" && "$1" == "install" ]]; then
    systemctl enable $servername.service
fi