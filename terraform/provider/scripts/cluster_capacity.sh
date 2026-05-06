#! /usr/bin/env bash

set -euo pipefail

INPUT="$(cat)"

if [[ -z "$INPUT" ]]; then
  echo "No input provided"
  exit 1
fi

export GOVC_URL=$(echo "$INPUT" | jq -r '.vcenter_server')
export GOVC_USERNAME=$(echo "$INPUT" | jq -r '.vcenter_username')
export GOVC_PASSWORD=$(echo "$INPUT" | jq -r '.vcenter_password')
export GOVC_INSECURE=$(echo "$INPUT" | jq -r '.insecure')

DATACENTER=$(echo "$INPUT" | jq -r '.datacenter')
CLUSTER=$(echo "$INPUT" | jq -r '.cluster')

CLUSTER_PATH="$(govc find /${DATACENTER} -type c -name="$CLUSTER" | head -n 1)"

if [[ -z $CLUSTER_PATH ]]; then
  echo "Cluster not found: $CLUSTER in datacenter: $DATACENTER"
  exit 1
fi

json="$(govc object.collect -json "$CLUSTER_PATH" summary)"

cpu_capacity="$(echo "$json" | jq -r '.[] | select(.Name=="summary") | .Val.TotalCpu')"
mem_capacity="$(echo "$json" | jq -r '.[] | select(.Name=="summary") | .Val.TotalMemory / 1024 / 1024 | floor')"
vsan_capacity="$(echo "$json" | jq -r '.[] | select(.Name=="summary") | .Val.TotalVsanStorage')"
total_hosts="$(echo "$json" | jq -r '.[] | select(.Name=="summary") | .Val.NumHosts')"
total_cores="$(echo "$json" | jq -r '.[] | select(.Name=="summary") | .Val.NumCpuCores')"
vsan_capacity_mb=$((vsan_capacity / 1024 / 1024))

jq -n \
  --arg total_hosts "$total_hosts" \
  --arg cpu_capacity "$cpu_capacity" \
  --arg total_cores "$total_cores" \
  --arg mem_capacity "$mem_capacity" \
  --arg vsan_capacity_mb "$vsan_capacity_mb" \
  '{
    total_hosts: $total_hosts,
    cpu_capacity: $cpu_capacity,
    total_cores: $total_cores,
    mem_capacity: $mem_capacity,
    vsan_capacity: $vsan_capacity_mb
  }'
