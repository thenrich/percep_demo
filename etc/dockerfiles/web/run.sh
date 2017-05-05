#!/bin/bash

. /common.sh

# Wait for successful connection to MySQL before starting
SUCCESSFUL_CONNECTIONS=0
NEEDED_SUCCESSFUL=5
check_mysql() {
    /app/bin/mysql_check
    if [ $? -eq 0 ]; then
        SUCCESSFUL_CONNECTIONS=$((SUCCESSFUL_CONNECTIONS+1))
    fi
}

check_mysql
while [ $SUCCESSFUL_CONNECTIONS -lt $NEEDED_SUCCESSFUL ]; do
    check_mysql
    echo "Insufficient successful connections to MySQL, retrying..."
    sleep 1
done

/app/bin/perceptyx_test