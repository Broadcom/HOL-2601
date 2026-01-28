#!/bin/bash
R='\e[91m'
G='\e[92m'
Y='\e[93m'
B='\e[94m'
M='\e[95m'
C='\e[96m'
W='\e[97m'
NC='\e[0m'
set -euo pipefail

# --- config ---
PASSWORD_FILE="/home/holuser/Desktop/PASSWORD.txt"
VCSA_HOST="vc-wld01-a.site-a.vcf.lab"
VCSA_USER="root"

# Supervisor **VIP** for this cluster
SUPERVISOR_IP="10.1.1.85"

SSH_OPTS="-o StrictHostKeyChecking=accept-new"

# --- sanity checks ---
if ! command -v sshpass >/dev/null 2>&1; then
  echo "Error: sshpass is not installed."
  exit 1
fi

if [ ! -f "$PASSWORD_FILE" ]; then
  echo "Error: password file $PASSWORD_FILE not found."
  exit 1
fi

vcsa_password="$(<"$PASSWORD_FILE")"
if [ -z "$vcsa_password" ]; then
  echo "Error: VCSA password is empty in $PASSWORD_FILE."
  exit 1
fi

echo "Retrieving supervisor password from VCSA $VCSA_HOST ..."

decrypt_output="$(
  sshpass -p "$vcsa_password" \
    ssh $SSH_OPTS "${VCSA_USER}@${VCSA_HOST}" \
    "/usr/lib/vmware-wcp/decryptK8Pwd.py"
)"

# First try to find the PWD for the specific VIP (10.1.1.85)
supervisor_password="$(
  printf '%s\n' "$decrypt_output" | \
  awk -v target_ip="$SUPERVISOR_IP" '
    $1 == "IP:" && $2 == target_ip {
      # next line should be the PWD line
      getline;
      sub(/^PWD:[[:space:]]*/, "", $0);
      print;
      exit;
    }
  '
)"

# Fallback: if that fails, just take the first PWD line
if [ -z "$supervisor_password" ]; then
  supervisor_password="$(
    printf '%s\n' "$decrypt_output" | \
    awk '
      $1 == "PWD:" {
        sub(/^PWD:[[:space:]]*/, "", $0);
        print;
        exit;
      }
    '
  )"
fi

if [ -z "$supervisor_password" ]; then
  echo "Error: could not extract supervisor password from decryptK8Pwd.py output."
  exit 1
fi

echo "Connecting to supervisor VIP ${SUPERVISOR_IP} and restarting CNS storage quota components..."

sshpass -p "$supervisor_password" \
  ssh $SSH_OPTS "root@${SUPERVISOR_IP}" <<'EOF'
set -e

echo "Deleting storage quota cert secrets (if present)..."
kubectl delete secret -n vmware-system-cert-manager storage-quota-root-ca-secret --ignore-not-found
kubectl delete secret -n kube-system storage-quota-webhook-server-internal-cert --ignore-not-found
kubectl delete secret -n kube-system cns-storage-quota-extension-cert --ignore-not-found

echo "Restarting CNS storage quota deployments..."
kubectl -n kube-system rollout restart deploy cns-storage-quota-extension
kubectl -n kube-system rollout restart deploy storage-quota-webhook

echo "Waiting for deployments to become ready..."
kubectl -n kube-system rollout status deploy cns-storage-quota-extension --timeout=300s
kubectl -n kube-system rollout status deploy storage-quota-webhook --timeout=300s

echo "CNS storage quota components successfully restarted."
EOF

echo "Done."