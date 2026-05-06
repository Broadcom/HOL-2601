#! /usr/bin/env bash

set -euo pipefail

INPUT="$(cat)"
if [[ -z "$INPUT" ]]; then
  echo "No input provided"
  exit 1
fi

VCENTER=$(echo "$INPUT" | jq -r '.vcenter_server')
USERNAME=$(echo "$INPUT" | jq -r '.vcenter_username')
PASSWORD=$(echo "$INPUT" | jq -r '.vcenter_password')
INSECURE=$(echo "$INPUT" | jq -r '.insecure')
DATACENTER=$(echo "$INPUT" | jq -r '.datacenter')
CLUSTER_NAME=$(echo "$INPUT" | jq -r '.cluster')

export GOVC_URL="$VCENTER"
export GOVC_USERNAME="$USERNAME"
export GOVC_PASSWORD="$PASSWORD"
export GOVC_INSECURE="$INSECURE"

json="$(govc cluster.info -json "$CLUSTER_NAME")"
cpu_capacity="$(echo "$json" | jq -r '.Clusters[0].Summary.TotalCpu')"
mem_capacity="$(echo "$json" | jq -r '.Clusters[0].Summary.TotalMemory')"
vsan_capacity="$(echo "$json" | jq -r '.Clusters[0].Summary.TotalVsanStorage')"
vsan_capacity_mb=$((vsan_capacity / 1024 / 1024))

jq -n \
  --arg cpu_capacity "$cpu_capacity" \
  --arg mem_capacity "$mem_capacity" \
  --arg vsan_capacity_mb "$vsan_capacity_mb" \
  '{
    cpu_capacity: $cpu_capacity,
    mem_capacity: $mem_capacity,
    vsan_capacity: $vsan_capacity_mb
  }'
