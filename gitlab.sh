#!/bin/bash
set -e
 
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOKEN=$(</home/holuser/gitlab.txt)
GITLAB_REPO_DIR="${SCRIPT_DIR}/gitlab"
BRANCH="main"
USERNAME="hol.admin"
REMOTE_URL="https://${USERNAME}:${TOKEN}@gitlab.site-a.vcf.lab/hol.admin/hol-all-apps.git"
REMOTE_NAME="origin"

if [ ! -d "$GITLAB_REPO_DIR" ]; then
    echo "[INFO] Gitlab folder missing."
    exit 1
fi

if [ -z "$TOKEN" ]; then
    echo "[ERROR] GitLab token is empty. Please ensure /home/holuser/gitlab.txt contains the token."
    exit 1
fi

cd "$GITLAB_REPO_DIR" || { echo "[ERROR] Failed to change directory to $GITLAB_REPO_DIR"; exit 1; }

if [ -d ".git" ]; then
    echo "[INFO] Git repository already initialized."
else
    echo "[INFO] Initializing Git repository..."
    git init
fi

git config user.name "hol.admin"
git config user.email "hol.admin@rainpole.io"

if ! git remote get-url "$REMOTE_NAME" > /dev/null 2>&1; then
    echo "[INFO] Adding remote '${REMOTE_NAME}' with URL '${REMOTE_URL}'..."
    git remote add "$REMOTE_NAME" "$REMOTE_URL"
else
    echo "[INFO] Remote '${REMOTE_NAME}' already exists. Updating URL to '${REMOTE_URL}'..."
    git remote set-url "$REMOTE_NAME" "$REMOTE_URL"
fi

echo "[INFO] Fetching from remote '${REMOTE_NAME}'..."
git fetch "$REMOTE_NAME"

if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    echo "[INFO] Branch '${BRANCH}' already exists locally. Checking out branch..."
    git checkout "$BRANCH"
else
    if git show-ref --verify --quiet "refs/remotes/$REMOTE_NAME/$BRANCH"; then
        echo "[INFO] Creating local branch '${BRANCH}' from remote '${REMOTE_NAME}/${BRANCH}'..."
        git checkout -b "${BRANCH}" --track "${REMOTE_NAME}/${BRANCH}" 
    else
        echo "[INFO] Branch '${BRANCH}' does not exist. Creating branch..."
        git checkout -b "${BRANCH}"
    fi
fi

if git show-ref --verify --quiet "refs/remotes/$REMOTE_NAME/$BRANCH"; then
    echo "[INFO] Pulling latest changes from remote '${REMOTE_NAME}' branch '${BRANCH}'..."
    git pull "$REMOTE_NAME" "$BRANCH" --no-rebase
else
    echo "[INFO] Remote branch '${REMOTE_NAME}/${BRANCH}' does not exist. Skipping pull."
fi

echo "[INFO] Git repository setup complete. Current branch: $(git rev-parse --abrev-ref HEAD)"

git add .

if ! git diff --cached --quiet; then
    echo "[INFO] Committing changes to Git repository..."
    git commit -m "Commit for GitLab repository - $(date +%s)"
else
    echo "[INFO] No changes to commit."
fi

echo "[INFO] Pushing to GitLab repository..."
git push -u "$REMOTE_NAME" "${BRANCH}" --force 
