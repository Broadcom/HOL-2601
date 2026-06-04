#! /usr/bin/env bash

terraform -chdir=tenant destroy -auto-approve
terraform -chdir=provider destroy -auto-approve

