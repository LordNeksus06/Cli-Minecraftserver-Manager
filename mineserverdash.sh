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

    bash ./src/installer.sh "$memorysize" "$servername" "$mcversion" "$mctype"

    bash ./src/systemd.sh $servername
}

backup() {
    echo "Backup causes a server stop to prevent data corruption in the backup files. Do you want to start the Server after the Backup? (Y/n)" start_after_backup

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

first_argument="$1"

case "$1" in                                                                                                                # What is the first argument
    install) check_root; shift; arguments "$@"; install;;
    backup) check_root; systemd_configuration; shift;;
    *) echo "The Argument $1 doesn't exist"; show_help; exit 1;;
esac

# Autostart at installation

if [[ "$autostart" == "true" && "$first_argument" == "install" ]]; then
    systemctl enable $servername.service
fi