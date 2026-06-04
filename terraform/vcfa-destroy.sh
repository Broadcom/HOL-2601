#! /usr/bin/env bash

terraform -chdir=provider destroy -auto-approve
terraform -chdir=tenant destroy -auto-approve
