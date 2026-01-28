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
remote_hosts="hosts.txt"

remote_user="holuser"
ssh_options="-n -q -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 -o LogLevel=ERROR"
scp_options="-o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 -o BatchMode=yes -o LogLevel=ERROR"
source_files=(
    /home/holuser/labfiles/hol-2601-50/repo.sh
    /home/holuser/labfiles/hol-2601-50/agent.sh
)

remote_folder="/tmp"

source_agent_file="/home/holuser/labfiles/hol-2601-50/repo.sh"
remote_agent_file="/tmp/repo.sh"

if [ -z "$password" ]; then
    echo -e "Error: Password is empty. Please ensure PASSWORD.txt contains the correct password."
    exit 1
fi

[[ -f "$remote_hosts" ]] || { echo -e "$remote_hosts file not found!"; exit 1; }

for file in "${source_files[@]}"; do
    [[ -f "$file" ]] || { echo -e "$file file not found!"; exit 1; }
done

while IFS= read -r host || [[ -n "$host" ]]; do

    [[ -z "$host" || "$host" =~ ^# ]] && continue

    echo -e "${B}Processing host: ${C}${host}${NC}"
    for file in "${source_files[@]}"; do
        remote_file="${remote_folder}/${file##*/}"
        sshpass -p "$password" scp "$file" "${remote_user}@${host}:$remote_file" && echo -e "${G}File: $file copied successfully to ${host}:${remote_file}${NC}" || { echo -e "${R}Failed to copy file: $file to ${host}:${remote_file}${NC}"; continue; }
        sshpass -p "$password" ssh $ssh_options "${remote_user}@${host}" "echo $password | sudo -S bash $remote_file" > /dev/null 2>&1 && echo -e "${G}Script ${remote_file} executed successfully on ${host}${NC}" || { echo -e "${R}Failed to execute ${remote_file} script on ${host}${NC}"; continue; }
        sshpass -p "$password" ssh $ssh_options "${remote_user}@${host}" "rm $remote_file" > /dev/null 2>&1 && echo -e "${G}File ${remote_file} removed successfully on ${host}${NC}" || { echo -e "${R}Failed to remove ${remote_file} script on ${host}${NC}"; continue; }
    done

    sshpass -p "$password" ssh $ssh_options "${remote_user}@${host}" "echo $password | sudo -S apt -y install apache2" > /dev/null 2>&1 && echo -e "${G}Apache 2 successfully installed on ${host}${NC}" || { echo -e "${R}Failed to install Apache 2 on ${host}${NC}"; continue; }
    sshpass -p "$password" ssh $ssh_options "${remote_user}@${host}" "echo $password | sudo -S apt -y install mysql-server" > /dev/null 2>&1 && echo -e "${G}MySQL server successfully installed on ${host}${NC}" || { echo -e "${R}Failed to install MySQL server on ${host}${NC}"; continue; }

done < "$remote_hosts"
