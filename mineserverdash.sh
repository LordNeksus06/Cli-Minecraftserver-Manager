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

git pull "$repository_link"

autostart="false"

if [ ! -d "$installationfolder" ]; then
    echo "The installationfolder doesn't exist. Check /config.conf"
    exit 0
fi

if [ $# -eq 0 ]; then
    echo "You don't have specified an action. Use --help for more information"
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --install | -i)  # Beide Optionen, --install und -i, werden hier abgefangen
            minecraftversiontype=$(get_argument "--install" "$2")
            shift 2
            ;;
        --memory)
            memorysize=$(get_argument "--memory" "$2")
            shift 2
            ;;
        --servername)
            servername=$(get_argument "--servername" "$2")
            shift 2
            ;;
        --serverversion)
            serverversion=$(get_argument "--serverversion" "$2")
            shift 2
            ;;
        --autostart)
            autostart="true"
            shift
            ;;
        --help | -h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown parameter: $1"
            echo "Use --help for help"
            exit 0
            ;;
    esac
done

echo "$minecraftversiontype"
echo "$memorysize"

if [[ "$minecraftversiontype" == "vanilla" ]]; then
    bash ./src/installer.sh vanilla "$servername" "$serverversion" "$memorysize"
fi

if [[ "$autostart" == "true" ]]; then
    bash ./src/autostart.sh "$servername"
fi