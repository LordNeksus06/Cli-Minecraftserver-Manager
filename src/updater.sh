#!/bin/bash

source ../config.conf

versionlink="https://raw.githubusercontent.com/LordNeksus06/Cli-Minecraftserver-Manager/refs/heads/main/newestversion.txt"

version=$(wget -q -O - "$versionlink")

echo "$version"