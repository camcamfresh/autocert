#!/bin/sh

if [ ! -e '/config/autocert.pipe' ]; then
    mkfifo -m 600 /config/autocert.pipe;
fi

while true; do
    if read MSG; then
        case "$MSG" in
            ('autocert.sh '*) $MSG &;;
            (*) autocert.sh &;;
        esac
    fi
done < /config/autocert.pipe;

rm -f /config/autocert.pipe;
