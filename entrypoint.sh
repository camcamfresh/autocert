#!/bin/sh
# Author : Cameron S.
# License: https://www.gnu.org/licenses/gpl-3.0.en.html

# Environment Validation
if [ ! "$DEFAULT_EMAIL" ]; then
	echo 'entrypoint.sh: WARNING: Enviroment Variable "DEFAULT_EMAIL" is not set.';
elif [ ! -d "/config" ]; then
	echo 'entrypoint.sh: Directory "/config" was not found.' > /dev/stderr;
	exit 1
elif [ ! -r "/config/luadns.ini" ]; then
	echo 'entrypoint.sh: Credential file luadns.ini was not found in "/config"' > /dev/stderr;
	exit 1;
fi

# Setup Cron for Renewals
echo '0 */6 * * * autocert.sh renew' | crontab -;
crond;

# Kill entire process group when this process dies.
trap 'rm -f /config/cert/autocert.sock; trap - SIGTERM && kill 0' SIGINT SIGTERM EXIT;

# Remove preexisting UNIX socket if present
if [ -r /config/cert/autocert.sock ]; then
	rm -f /config/cert/autocert.sock;
fi

# Listen for Request on UNIX Socket
while true; do
	MSG=$(socat unix-listen:/config/cert/autocert.sock stdout);
	case "$MSG" in
        'autocert.sh '*) 
            $MSG &;;
        *) 
            echo "entrypoint: Invalid Request on Autocert Pipe: $MSG" > /dev/stderr;
            autocert.sh &;;
    esac
done

exit 1;