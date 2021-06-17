#!/bin/sh
# Author : Cameron S.
# License: https://www.gnu.org/licenses/gpl-3.0.en.html

[ -e '/config/certs/autocert.pipe' ] && rm -f /config/certs/autocert.pipe;
mkfifo -m 222 /config/certs/autocert.pipe;

# Kill process group when this process dies.
trap 'rm -f /config/certs/autocert.pipe; trap - SIGTERM && kill 0' SIGINT SIGTERM EXIT;

while true; do
    if read MSG; then
        case "$MSG" in
            'autocert.sh '*) 
                $MSG &;;
            *) 
                echo "Invalid Request on Autocert Pipe: $MSG" > /dev/stderr;
                autocert.sh &;;
        esac
    fi
done < /config/certs/autocert.pipe;
