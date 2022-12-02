#!/bin/bash
open=$'\001'
close=$'\002'
GREEN=$open`tput setaf 2`$close
MAGENTA=$open`tput setaf 5`$close
BOLD=$open$(tput bold)$close
RESET=$open`tput sgr0`$close

echo "${GREEN}==========================================="
echo
echo ${BOLD}Script env variables :${RESET}
DACHS_PODNAME="docker-dachs"
DACHS_POD_NETWOR_NAME="${DACHS_PODNAME}-net"
DACHS_IMAGE_VERSION="latest"
DACH_AWSTATS_IMAGE_VERSION=${DACHS_IMAGE_VERSION}

echo ${MAGENTA}DACHS_PODNAME${RESET}=$DACHS_PODNAME
echo ${MAGENTA}DACHS_POD_NETWOR_NAME${RESET}=$DACHS_POD_NETWOR_NAME
echo ${MAGENTA}DACHS_IMAGE_VERSION${RESET}=$DACHS_IMAGE_VERSION
echo ${MAGENTA}DACH_AWSTATS_IMAGE_VERSION${RESET}=$DACH_AWSTATS_IMAGE_VERSION
echo
echo "${GREEN}${BOLD}Persistent data locations${RESET}"
# persistent dachs log data
DACHS_LOGS_PATH=${DACHS_LOGS_PATH:-../containers-storage/logs/dachs}
# persistent postgres data
DACHS_POSTGRES_PATH=${DACHS_POSTGRES_PATH:-../containers-storage/postgresql}
# persistent RD data
DACHS_DATA_PATH=${DACHS_DATA_PATH:-../containers-input}

echo ${MAGENTA}DACHS_LOGS_PATH${RESET}=${DACHS_LOGS_PATH}
echo ${MAGENTA}DACHS_POSTGRES_PATH${RESET}=${DACHS_POSTGRES_PATH}
echo ${MAGENTA}DACHS_DATA_PATH${RESET}=${DACHS_DATA_PATH}
echo
echo "${GREEN}=====================================================${RESET}"

podman pod rm -f ${DACHS_PODNAME}
podman network create $DACHS_POD_NETWOR_NAME -d bridge
podman pod create \
        --network $DACHS_POD_NETWOR_NAME \
        --name ${DACHS_PODNAME} \
        --hostname ${DACHS_PODNAME} \
        -p 8080:8080 \

podman run -d \
    --name dachs \
    --expose 8080 \
    --pod ${DACHS_PODNAME} \
    --tty \
    -e TZ="Europe/Berlin" \
     -v ${DACHS_LOGS_PATH}:/var/gavo/logs \
     -v ${DACHS_DATA_PATH}:/var/gavo/inputs \
 docker.io/gavodachs/dachs:${DACHS_IMAGE_VERSION}

    # --hostname dachs \
podman run -d \
    --name awstats \
    --expose 80 \
    --pod ${DACHS_PODNAME} \
    --tty \
    -e TZ="Europe/Berlin" \
     -v ${DACHS_LOGS_PATH}:/var/gavo/logs:ro \
 docker.io/gavodachs/awstats:${DACH_AWSTATS_IMAGE_VERSION}

    # --hostname awstats \
