#!/bin/bash

# test: ./installer.sh vanilla servername 1.19.2 3G

source ./config.conf

memorysize="$1"
servername="$2"
mcversion="$3"
mctype="$4"

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
            echo "F  r die Version $mcversion ist keine Server-JAR verf  gbar."
            exit 1
        fi

        echo "Lade Minecraft-Server $mcversion herunter..."
        curl -o "/$folder/server_$mcversion.jar" $server_url
    }
    minecraft_manifest

    # Configuration of the server

    echo "eula=true" > /$folder/eula.txt 

    echo "#!/bin/sh" >> /$folder/start.sh
    echo "cd /$folder" >> /$folder/start.sh
    echo "java -Xms$memory -Xmx$memory -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:MaxGCPauseMillis=50 -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineSize=128 -XX:+OptimizeStringConcat -XX:+DisableExplicitGC -XX:ParallelGCThreads=4 -XX:ConcGCThreads=2 -XX:InitiatingHeapOccupancyPercent=15 -XX:+PerfDisableSharedMem -Dusing.aikars.flags=true -Dfile.encoding=UTF-8 -jar server_$mcversion.jar nogui" >> /$folder/start.sh
    echo "exit 0" >> /$folder/start.sh

    chmod +x /$folder/start.sh
}

folder=/$installationfolder/server/$servername
mkdir /$folder

if [[ "$mctype" == "vanilla" ]]; then
    echo "Installing the vanilla server"
    vanilla
fi

exit 0
