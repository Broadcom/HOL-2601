#! /usr/bin/env bash

terraform -chdir=provider init
terraform -chdir=provider apply -auto-approve

terraform -chdir=tenant init
terraform -chdir=tenant apply -auto-approve