#!/usr/bin/env bash

# Check for /etc/app_config/environment and export variables if it exists
ENV_FILE=/etc/app_config/environment

if [ -f $ENV_FILE ]; then
    set -a
    . $ENV_FILE
    set +a
fi