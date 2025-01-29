#!/bin/bash

show_help() {
    echo "Verwendung: $0 [OPTION]"
    echo ""
    echo "Optionen:"
    echo "  --install       Installiert das Programm"
    echo "  --uninstall     Deinstalliert das Programm"
    echo "  --help          Zeigt diese Hilfe an"
}

source ./config.conf

autostart="false"
backup=""

echo "Search for new version"

git fetch
git checkout -- config.conf
git pull

if [ ! -d "$installationfolder" ]; then
    echo "The installationfolder doesn't exist. Check /config.conf"
    exit 0
fi

if [ $# -eq 0 ]; then
    echo "You don't have specified an action. Use --help for more information"
    exit 1
fi

get_arg() {
    [[ -n "$2" && "$2" != -* ]] && eval "$3='$2'" || { echo "$1 needs an argument."; exit 1; };
}

[[ $# -eq 0 ]] && show_help && exit 1

while [[ $# -gt 0 ]]; do
    case "$1" in 
        --install|-i) get_arg "$1" "$2" minecraftversiontype; shift 2 ;;
        --memory|-m) get_arg "$1" "$2" memorysize; shift 2 ;;
        --servername) get_arg "$1" "$2" servername; shift 2 ;;
        --mcversion|-v) get_arg "$1" "$2" mcversion; shift 2 ;;
        --backup) get_arg "$1" "$2" backup; shift 2 ;;
        --autostart) autostart="true"; shift ;;
        --help|-h) show_help; exit ;;
        *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
    esac 
done 

if [[ "$minecraftversiontype" == "vanilla" ]]; then
    bash ./src/installer.sh vanilla "$servername" "$mcversion" "$memorysize"
fi

if [[ $backup != ""]]; then
    bash ./src/backup.sh $backup
fi

#if [[ "$autostart" == "true" ]]; then
#    bash ./src/autostart.sh "$servername"
#fi