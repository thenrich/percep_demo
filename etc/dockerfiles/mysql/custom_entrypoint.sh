#!/bin/bash

aws s3 cp s3://com.perceptyx.ecs.config/environ-dev /etc/environ || true

if [ -f /etc/environ ]; then
	set -a
	source /etc/environ
	set +a
fi

exec /entrypoint.sh "$@"