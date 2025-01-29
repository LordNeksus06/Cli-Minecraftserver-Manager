#!/bin/bash

source ./config.conf

version=$(wget -q -O - "$versionlink")

echo "$version"

if [[ "$current_version" != "$version" ]]; then
    git pull https://github.com/LordNeksus06/Cli-Minecraftserver-Manager.git
fi