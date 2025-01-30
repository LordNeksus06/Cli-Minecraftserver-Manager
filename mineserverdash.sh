#!/bin/bash

show_help() {
    echo "Verwendung: $0 [OPTION]"
    echo ""
    echo "Optionen:"
    echo "  --install       Installiert das Programm"
    echo "  --uninstall     Deinstalliert das Programm"
    echo "  --help          Zeigt diese Hilfe an"
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
}

backup() {
    if [[ "$servername" == "" ]]; then
        echo "You haven't specified the server! Please select one of the following"
        echo "--------------------------------------------"
        
        ls /$installationfolder/server

        echo "--------------------------------------------"

        read -p "Select the Server: " servername
    fi

    bash ./src/backup.sh "$servername"
}

source ./config.conf

if [ ! -d "$installationfolder" ]; then                                                                                     # Check the installationfolder
    echo "The installationfolder doesn't exist. Check /config.conf"
    exit 0
fi

if [ ! -d "$installationfolder/server" ]; then                                                                                     # Check the installationfolder
    mkdir $installationfolder/server
fi

if [ ! -d "$installationfolder/backups" ]; then                                                                                     # Check the installationfolder
    mkdir $installationfolder/backups
fi

if [ $# -eq 0 ]; then                                                                                                       # Check the command
    echo "You don't have specified an action. Use --help for more information"
    exit 1
fi

case "$1" in                                                                                                                # What is the first argument
    install) shift; arguments "$@"; install;;
    backup) backup; shift;;
    *) echo "The Argument $1 doesn't exist"; show_help; exit 1;;
esac