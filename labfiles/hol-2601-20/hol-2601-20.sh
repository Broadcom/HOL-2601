SCRIPT_PATH=$(dirname "$(readlink -f "$0")")

python3 -m venv ~/gitlab-venv
source ~/gitlab-venv/bin/activate
pip install pyvmomi python-gitlab pip-system-certs
python3 $SCRIPT_PATH/hol-2601-20.py