#! /usr/bin/env bash

set -euo pipefail

export GOVC_URL="vc-wld01-a.site-a.vcf.lab"
export GOVC_USERNAME="administrator@wld.sso"
export GOVC_PASSWORD=$(</home/holuser/creds.txt)
export GOVC_INSECURE="true"

DATACENTER="dc-a"
CLUSTER="cluster-wld01-01a"
DATASTORE="vsan-wld01-01a"

govc find "/${DATACENTER}" -type c -name "$CLUSTER" | head -n 1
CLUSTER_PATH="$(govc find "/${DATACENTER}" -type c -name "$CLUSTER" | head -n 1)"

if [[ -z $CLUSTER_PATH ]]; then
  echo "Cluster not found: $CLUSTER in datacenter: $DATACENTER"
  exit 1
fi

govc object.collect "$CLUSTER_PATH" summary.totalCpu summary.totalMemory summary.numHosts summary.numCpuCores
govc datastore.info "$DATASTORE"

json="$(govc object.collect -json "$CLUSTER_PATH" summary.totalCpu summary.totalMemory summary.numHosts summary.numCpuCores)"
ds_json="$(govc datastore.info -json "$DATASTORE")"

cpu_capacity="$(echo "$json" | jq -r '.[] | select(.Name=="summary.totalCpu") | .val')"
mem_capacity="$(echo "$json" | jq -r '.[] | select(.Name=="summary.totalMemory") | .val / 1024 / 1024 | floor')"
vsan_capacity="$(echo "$ds_json" | jq -r '.Datastores[0].capacity')"
total_hosts="$(echo "$json" | jq -r '.[] | select(.Name=="summary.numHosts") | .val')"
total_cores="$(echo "$json" | jq -r '.[] | select(.Name=="summary.numCpuCores") | .val')"

jq -n \
  --arg total_hosts "$total_hosts" \
  --arg cpu_capacity "$cpu_capacity" \
  --arg mem_capacity "$mem_capacity" \
  --arg vsan_capacity "$vsan_capacity" \
  --arg total_cores "$total_cores" \
  '{
    total_hosts: $total_hosts,
    cpu_capacity: $cpu_capacity,
    total_cores: $total_cores,
    mem_capacity: $mem_capacity,
    vsan_capacity: $vsan_capacity
  }'
