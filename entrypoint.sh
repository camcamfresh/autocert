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

# Start Cron for Renewals
crond;

# Listen for Request on UNIX Socket
trap 'rm -f /config/cert/autocert.sock; trap - SIGTERM && kill 0' SIGINT SIGTERM EXIT;

if [ -r /config/cert/autocert.sock ]; then
	rm -f /config/cert/autocert.sock;
fi

# Remove preexisting UNIX socket if present
while true; do
	MSG=$(socat unix-listen:/config/cert/autocert.sock stdout);
	case "$MSG" in
        'autocert.sh '*) 
            $MSG &;;
        *) 
            echo "Invalid Request on Autocert Pipe: $MSG" > /dev/stderr;
            autocert.sh &;;
    esac
done

exit 1;