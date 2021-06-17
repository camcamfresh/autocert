#!/bin/sh
# Author : Cameron S.
# License: https://www.gnu.org/licenses/gpl-3.0.en.html

# Environment Validation
if [ ! "$EMAIL" ]; then
	echo 'entrypoint.sh: WARNING: Enviroment Variable "EMAIL" is not set.';
elif [ ! -d "/config" ]; then
	echo 'entrypoint.sh: Directory "/config" was not found.' > /dev/stderr;
	exit 1
elif [ ! -r "/config/luadns.ini" ]; then
	echo 'entrypoint.sh: Credential file luadns.ini was not found in "/config"' > /dev/stderr;
	exit 1;
fi

# Kill entire process group when this process dies.
trap 'trap - SIGTERM && kill 0' SIGINT SIGTERM EXIT;

if [ -n "$DOMAINS" ]; then
	echo 'entrypoint.sh: Requesting Certificates for domains found in $DOMAINS environment variable.';
	for DOMAIN in $DOMAINS; do
		autocert.sh certonly --domains "$DOMAIN";
	done;
fi

# Start Jobs
createAutocertPipe.sh &
crond -f;
exit 1;