#!/bin/sh
# Author : Cameron S.
# License: https://www.gnu.org/licenses/gpl-3.0.en.html

# Environment Validation
if [ ! "$EMAIL" ]; then
	echo 'requestSSL.sh: Enviroment Variable "EMAIL" is not set.' > /dev/stderr;
	exit 1;
elif [ ! -d "/config" ]; then
	echo 'requestSSL.sh: Enviroment Variable "CONFIG_DIR" is not set.' > /dev/stderr;
	exit 1
elif [ ! -r "/config/luadns.ini" ]; then
	echo "requestSSL.sh: Credential file luadns.ini was not found in $CONFIG_DIR." > /dev/stderr;
	exit 1;
fi

# Start Jobs
autocertPipe.sh &
crond -f;
exit 1;