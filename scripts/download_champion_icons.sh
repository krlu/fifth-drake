#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 [-a <Riot Games API Key>]"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

DDRAGON_VERSION_BASE_URL="https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions"
CHAMPIONS_BASE_URL="https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion"
DEST_PATH="../public/champion/"

if [ ! -d ${DEST_PATH} ]; then
    mkdir ${DEST_PATH}
fi

# Key used to authenticate with Riot API
API_KEY=

# Parse Arguments
while getopts "a:" o; do
    case ${o} in
        a) # Riot API Key
            API_KEY=${OPTARG}
            ;;
        *) # Other
            usage
            ;;
    esac
done

shift $((OPTIND-1))
# End Parse Arguments

# DDragon version
DDV=$(curl "${DDRAGON_VERSION_BASE_URL}?api_key=${API_KEY}" | jq '.[0]' | sed 's/"//g')
IMAGE_BASE_URL="http://ddragon.leagueoflegends.com/cdn/${DDV}/img/champion/"

# All Champion Icon image names
CHAMPIONS=$(curl "${CHAMPIONS_BASE_URL}?champData=image&api_key=${API_KEY}" | jq '.data | map(.image.full)')
NUM_CHAMPIONS=$(echo ${CHAMPIONS} | jq '. | length')

# Download each champion icon into public/champions/{champion}.png
for ((i = 0; i < ${NUM_CHAMPIONS}; i++)) do
    IMG_NAME=$(echo ${CHAMPIONS} | jq '.['${i}']' | sed 's/"//g')
    IMG_URL="${IMAGE_BASE_URL}${IMG_NAME}"
    echo "downloading: ${IMG_URL}"
    curl "${IMG_URL}" > "${DEST_PATH}${IMG_NAME}"
done
