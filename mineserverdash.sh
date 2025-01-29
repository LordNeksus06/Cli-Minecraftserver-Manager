#!/bin/bash

show_help() {
    echo "Verwendung: $0 [OPTION]"
    echo ""
    echo "Optionen:"
    echo "  --install       Installiert das Programm"
    echo "  --uninstall     Deinstalliert das Programm"
    echo "  --help          Zeigt diese Hilfe an"
}

bash /src/updater.sh



source ./config.conf

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
        --install)
            if [[ -n "$2" && "$2" != --* ]]; then
                case "$2" in
                    vanilla)
                        minecraftversiontype="$2"
                        shift 2
                        ;;
                    *)
                        echo "the type of minecraft doesn't exist."
                        exit 0
                esac
            else
                echo "Failure! --install needs an Argument"
                exit 0
            fi
            ;;
        --memory)
            if [[ -n "$2" && "$2" != --* ]]; then
                memorysize="$2"
                shift 2
            else
                echo "Failure! --memory needs an Argument"
                exit 0
            fi
            ;;
        --servername)
            if [[ -n "$2" && "$2" != --* ]]; then
                servername="$2"
                shift 2
            else
                echo "Failure! --servername needs an Argument"
                exit 0
            fi
            ;;
        --serverversion)
            if [[ -n "$2" && "$2" != --* ]]; then
                serverversion="$2"
                shift 2
            else
                echo "Failure! --serverversion needs an Argument"
                exit 0
            fi
            ;;
        --autostart)
            autostart="true"
            exit 0
            ;;
        --help)
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