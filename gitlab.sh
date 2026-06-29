#!/bin/bash
# Author: Christopher Lewis
# Version: 1.1
# Date: 2026-06-29
# Sync the local GitLab repo clone with the remote GitLab server.
#
# Changes from v1.0:
# - Removed `set -e`; git failures are now non-fatal (log a warning, exit 0).
# - Token file absence exits 0 with a warning instead of 1 with an error.
# - git fetch and git push use a retry loop (3 attempts, 30s delay) to tolerate
#   GitLab not being fully ready when this script runs during lab startup.
# - Fixed typo: --abrev-ref → --abbrev-ref.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOKEN_FILE="/home/holuser/gitlab.txt"
GITLAB_REPO_DIR="${SCRIPT_DIR}/gitlab"
BRANCH="main"
USERNAME="hol.admin"
REMOTE_NAME="origin"

# Non-fatal token check — GitLab sync is best-effort during lab startup
if [ ! -f "$TOKEN_FILE" ]; then
    echo "[WARN] GitLab token file $TOKEN_FILE not found — skipping GitLab sync."
    exit 0
fi

TOKEN=$(<"$TOKEN_FILE")
if [ -z "$TOKEN" ]; then
    echo "[WARN] GitLab token is empty in $TOKEN_FILE — skipping GitLab sync."
    exit 0
fi

REMOTE_URL="https://${USERNAME}:${TOKEN}@gitlab.site-a.vcf.lab/hol.admin/hol-all-apps.git"

if [ ! -d "$GITLAB_REPO_DIR" ]; then
    echo "[INFO] Gitlab folder missing at $GITLAB_REPO_DIR."
    exit 0
fi

cd "$GITLAB_REPO_DIR" || { echo "[ERROR] Failed to change directory to $GITLAB_REPO_DIR"; exit 0; }

if [ -d ".git" ]; then
    echo "[INFO] Git repository already initialized."
else
    echo "[INFO] Initializing Git repository..."
    git init
fi

git config user.name "hol.admin"
git config user.email "hol.admin@rainpole.io"

if ! git remote get-url "$REMOTE_NAME" > /dev/null 2>&1; then
    echo "[INFO] Adding remote '${REMOTE_NAME}'..."
    git remote add "$REMOTE_NAME" "$REMOTE_URL"
else
    echo "[INFO] Updating remote '${REMOTE_NAME}' URL..."
    git remote set-url "$REMOTE_NAME" "$REMOTE_URL"
fi

# Retry git fetch — GitLab may not be fully up at lab start time
fetch_ok=0
for attempt in 1 2 3; do
    echo "[INFO] git fetch attempt ${attempt}/3..."
    if git fetch "$REMOTE_NAME" 2>&1; then
        fetch_ok=1
        break
    fi
    echo "[WARN] git fetch failed on attempt ${attempt}, retrying in 30s..."
    sleep 30
done

if [ $fetch_ok -eq 0 ]; then
    echo "[WARN] git fetch failed after 3 attempts — skipping GitLab sync."
    exit 0
fi

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    echo "[INFO] Checking out existing branch '${BRANCH}'..."
    git checkout "$BRANCH"
else
    if git show-ref --verify --quiet "refs/remotes/$REMOTE_NAME/$BRANCH"; then
        echo "[INFO] Creating local branch '${BRANCH}' from remote..."
        git checkout -b "${BRANCH}" --track "${REMOTE_NAME}/${BRANCH}"
    else
        echo "[INFO] Branch '${BRANCH}' does not exist remotely — creating locally."
        git checkout -b "${BRANCH}"
    fi
fi

if git show-ref --verify --quiet "refs/remotes/$REMOTE_NAME/$BRANCH"; then
    echo "[INFO] Pulling latest changes from remote..."
    git pull "$REMOTE_NAME" "$BRANCH" --no-rebase || echo "[WARN] git pull failed — continuing with local state."
else
    echo "[INFO] Remote branch does not exist yet — skipping pull."
fi

echo "[INFO] Current branch: $(git rev-parse --abbrev-ref HEAD)"

git add .

if ! git diff --cached --quiet; then
    echo "[INFO] Committing changes..."
    git commit -m "Commit for GitLab repository - $(date +%s)"
else
    echo "[INFO] No changes to commit."
fi

# Retry git push
push_ok=0
for attempt in 1 2 3; do
    echo "[INFO] git push attempt ${attempt}/3..."
    if git push -u "$REMOTE_NAME" "${BRANCH}" --force 2>&1; then
        push_ok=1
        break
    fi
    echo "[WARN] git push failed on attempt ${attempt}, retrying in 30s..."
    sleep 30
done

if [ $push_ok -eq 0 ]; then
    echo "[WARN] git push failed after 3 attempts — GitLab sync incomplete but non-fatal."
    exit 0
fi

echo "[INFO] GitLab sync complete."
