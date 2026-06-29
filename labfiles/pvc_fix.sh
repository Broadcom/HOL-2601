#!/bin/bash
# Author: Christopher Lewis
# Version: 1.1
# Date: 2026-06-29
# Fix CNS storage quota certs and restart webhook deployments on the Supervisor cluster.
#
# Originally ran via SSH from the manager to the console VM (holuser@console), then
# from the console to vCenter to extract Supervisor credentials.  That chain introduced
# two brittle SSH hops: the manager→console hop frequently fails because the "console"
# hostname is not reliably resolvable from the manager, and it required the lab password
# to be present at /home/holuser/Desktop/PASSWORD.txt on the console VM.
#
# This version runs directly on the manager VM, reading the lab password from the
# standard manager credential file (/home/holuser/creds.txt) and SSHing straight to
# vCenter — the same pattern used by restart_k8s_webhooks.sh.
#
# Call from final.py as:  lsf.run_command('bash /vpodrepo/2026-labs/2601/labfiles/pvc_fix.sh')

R='\e[91m'
G='\e[92m'
Y='\e[93m'
NC='\e[0m'

# --- config ---
CREDS_FILE="/home/holuser/creds.txt"
VCSA_HOST="vc-wld01-a.site-a.vcf.lab"
VCSA_USER="root"
SUPERVISOR_IP="10.1.1.85"
SSH_OPTS="-o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -o ConnectTimeout=15"
MAX_VC_ATTEMPTS=5
VC_RETRY_DELAY=30

# --- sanity checks ---
if ! command -v sshpass >/dev/null 2>&1; then
    echo -e "${R}Error: sshpass is not installed.${NC}"
    exit 1
fi

if [ ! -f "$CREDS_FILE" ]; then
    echo -e "${R}Error: credentials file $CREDS_FILE not found.${NC}"
    exit 1
fi

vcsa_password="$(<"$CREDS_FILE")"
if [ -z "$vcsa_password" ]; then
    echo -e "${R}Error: credentials file $CREDS_FILE is empty.${NC}"
    exit 1
fi

echo "Retrieving supervisor password from VCSA $VCSA_HOST ..."

# Retry vCenter SSH — vCenter may not yet be SSH-ready after a cold boot
decrypt_output=""
vc_attempt=0
while [ $vc_attempt -lt $MAX_VC_ATTEMPTS ]; do
    vc_attempt=$((vc_attempt + 1))
    echo "  vCenter SSH attempt ${vc_attempt}/${MAX_VC_ATTEMPTS}..."
    if decrypt_output="$(
        sshpass -p "$vcsa_password" \
            ssh $SSH_OPTS "${VCSA_USER}@${VCSA_HOST}" \
            "/usr/lib/vmware-wcp/decryptK8Pwd.py" 2>&1
    )"; then
        echo "  Connected to vCenter successfully."
        break
    fi
    decrypt_output=""
    if [ $vc_attempt -lt $MAX_VC_ATTEMPTS ]; then
        echo "  Connection failed, retrying in ${VC_RETRY_DELAY}s..."
        sleep "$VC_RETRY_DELAY"
    fi
done

if [ -z "$decrypt_output" ]; then
    echo -e "${R}Error: could not connect to vCenter after ${MAX_VC_ATTEMPTS} attempts.${NC}"
    exit 1
fi

# Extract password for the specific Supervisor VIP first, fall back to first PWD line
supervisor_password="$(
    printf '%s\n' "$decrypt_output" | \
    awk -v target_ip="$SUPERVISOR_IP" '
        $1 == "IP:" && $2 == target_ip {
            getline;
            sub(/^PWD:[[:space:]]*/, "", $0);
            print;
            exit;
        }
    '
)"

if [ -z "$supervisor_password" ]; then
    supervisor_password="$(
        printf '%s\n' "$decrypt_output" | \
        awk '$1 == "PWD:" { sub(/^PWD:[[:space:]]*/, "", $0); print; exit; }'
    )"
fi

if [ -z "$supervisor_password" ]; then
    echo -e "${R}Error: could not extract supervisor password from decryptK8Pwd.py output.${NC}"
    exit 1
fi

echo -e "${G}Connecting to supervisor VIP ${SUPERVISOR_IP} and restarting CNS storage quota components...${NC}"

sshpass -p "$supervisor_password" \
    ssh $SSH_OPTS "root@${SUPERVISOR_IP}" <<'EOF'
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

echo -e "${G}Done.${NC}"
