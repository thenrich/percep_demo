#!/bin/bash

. /common.sh

# Every 30s, copy the latest config file into place
while true; do
    aws s3 cp s3://com.perceptyx.ecs.config/environ-$APP_ENV /etc/app_config/.environment_pre
    # If exit code is zero, copy into place
    if [ $? -eq 0 ]; then
        cp /etc/app_config/.environment_pre /etc/app_config/environment
    fi
    sleep 30;
done
