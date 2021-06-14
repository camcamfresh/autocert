#!/bin/sh
# Author : Cameron S.
# License: https://www.gnu.org/licenses/gpl-3.0.en.html

# Environment Validation
if [ ! "$EMAIL" ]; then
	echo 'requestSSL.sh: Enviroment Variable "EMAIL" is not set.' > /dev/stderr;
	exit 1;
elif [ ! "$CONFIG_DIR" ]; then
	echo 'requestSSL.sh: Enviroment Variable "CONFIG_DIR" is not set.' > /dev/stderr;
	exit 1
elif [ ! -r "$CONFIG_DIR/luadns.ini" ]; then
	echo "requestSSL.sh: Credential file luadns.ini was not found in $CONFIG_DIR." > /dev/stderr;
	exit 1;
fi

# Install Dependencies
apk update;
apk upgrade;
apk add py3-pip gcc python3-dev musl-dev libffi-dev cargo openssl-dev;
pip3 install -U pip certbot certbot-dns-luadns cryptography wheel;

# Initial Setup
chmod +x /usr/sbin/autocert.sh;
chmod +x /usr/sbin/autocertPipe.sh;
echo '*/5 * * * * autocert.sh renew' | crontab -;

# Start Jobs
autocertPipe.sh &
crond -f;
exit 1;