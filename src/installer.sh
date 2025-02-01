#!/bin/bash

# test: ./installer.sh vanilla servername 1.19.2 3G

source ./config.conf

servername="$1"
mcversion="$2"
mctype="$3"

echo "$@"

vanilla() {                         # Installation of the Vanilla Server
    minecraft_manifest() {              # minecraft version herunterladen
        curl -s $manifest_url -o version_manifest.json
        version_url=$(jq -r --arg MC_VERSION "$mcversion" '.versions[] | select(.id == $MC_VERSION) | .url' version_manifest.json)
        echo "$version_url"
        rm version_manifest.json
        if [ -z "$version_url" ]; then
            echo "The selected version $mcversion could not be found"
            exit 1
        fi

        server_url=$(curl -s $version_url | jq -r '.downloads.server.url')

        if [ -z "$server_url" ]; then
            echo "It is no $mcversion version available"
            exit 1
        fi

        echo "Lade Minecraft-Server $mcversion herunter..."
        curl -o "/$folder/server_$mcversion.jar" $server_url
    }
    minecraft_manifest

    # Configuration of the server

    echo "eula=true" > /$folder/eula.txt 
}

folder=/$installationfolder/cli-minecraftserver-manager/server/$servername
mkdir /$folder

if [[ "$mctype" == "vanilla" ]]; then
    echo "Installing the vanilla server"
    vanilla
fi

chown -R climinecraftservermanager:climinecraftservermanager "$folder"

exit 0
