#!/bin/sh
# Author : Cameron S.
# License: https://www.gnu.org/licenses/gpl-3.0.en.html

# Environment Validation
if [ ! "$EMAIL" ]; then
	echo 'requestSSL.sh: Enviroment Variable "EMAIL" is not set.' > /dev/stderr;
	exit 1;
elif [ ! -d "/config" ]; then
	echo 'requestSSL.sh: Directory "/config" was not found.' > /dev/stderr;
	exit 1
elif [ ! -r "/config/luadns.ini" ]; then
	echo 'requestSSL.sh: Credential file luadns.ini was not found in "/config"' > /dev/stderr;
	exit 1;
fi

# Start Jobs
createAutocertPipe.sh &
crond -f;
exit 1;