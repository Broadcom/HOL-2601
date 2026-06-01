#! /usr/bin/env bash

terraform -chdir=provider init -upgrade
terraform -chdir=provider apply -auto-approve

terraform -chdir=tenant init -upgrade
terraform -chdir=tenant apply -auto-approve