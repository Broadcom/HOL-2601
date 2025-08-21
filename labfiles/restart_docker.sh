#!/bin/bash

R='\e[91m'
G='\e[92m'
Y='\e[93m'
B='\e[94m'
M='\e[95m'
C='\e[96m'
W='\e[97m'
NC='\e[0m'

password=$(</home/holuser/Desktop/PASSWORD.txt)

remote_host="docker.site-a.vcf.lab"
remote_user="holuser"
ssh_options="-o StrictHostKeyChecking=accept-new"

interval=5
timeout=60
elapsed=0

if [ -z "$password" ]; then
    echo -e "Error: Password is empty. Please ensure PASSWORD.txt contains the correct password."
    exit 1
fi

echo -e "Stopping containers on ${C}${remote_user}@${remote_host}${NC} using ${C}${remote_command}${NC}"
remote_command="docker compose -f /opt/services.yaml down"

sshpass -p "${password}" ssh ${ssh_options} ${remote_user}@${remote_host} ${remote_command}

echo -e "Starting containers on ${C}${remote_user}@${remote_host}${NC} using ${C}${remote_command}${NC}"
remote_command="docker compose -f /opt/services.yaml up -d --build --wait"

sshpass -p "${password}" ssh ${ssh_options} ${remote_user}@${remote_host} ${remote_command}

remote_command="docker ps --format '{{.Names}}'"
echo -e "Fetching container names from ${C}${remote_user}@${remote_host}${NC} using ${C}${remote_command}${NC}"

containers=($(sshpass -p "${password}" ssh ${ssh_options} ${remote_user}@${remote_host} ${remote_command}))

for container in "${containers[@]}"; do

    while true; do
        
        health_status=$(sshpass -p "${password}" ssh ${ssh_options} ${remote_user}@${remote_host} "docker inspect --format='{{.State.Health.Status}}' $container" 2>/dev/null)
        echo -e "Checking health status of $container... ${Y}$health_status${NC}"
        if [ -z "$health_status" ]; then
            echo -e -e "${R}$container does not exist...${NC}"
            exit 1
        fi
        if [ "$health_status" = "healthy" ]; then 
            #echo -e -e "${G}$container is $health_status...${NC}"
            break
        elif [ "$health_status" = "unhealthy" ] || [ "$health_status" = "starting" ]; then
            if [ "$elapsed" -ge "$timeout" ]; then
                echo -e -e "${R}Timed out waiting for $container to become healthy...${NC}"
                exit 1
            fi
            sleep $interval
            elapsed=$((elapsed + interval))
            #echo -e -e "${G}$container is $health_status...${NC}"
        else
            echo -e -e "${R}$container container is not healthy (status: $health_status)...${NC}"
            exit 1
        fi
    done
done

