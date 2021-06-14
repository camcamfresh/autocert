#!/bin/sh

if [ ! -e '/config/autocert.pipe' ]; then
    mkfifo -m 600 /config/autocert.pipe;
fi

while read MSG; do
    case "$MSG" in
        ('autocert.sh'*) $msg &;;
        (*) autocert.sh &;;
    esac
    MSG=''
done < /config/autocert.pipe;
