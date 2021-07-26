#!/bin/sh
# Author : Cameron S.
# License: https://www.gnu.org/licenses/gpl-3.0.en.html

# Log Request
echo "$0: Script executed with args: ($*)";

invalid_usage() {
    echo "$0: Invalid usage; this is a daemon wrapper around certbot that adds authentication.";
    certbot -h | sed 's/certbot \[SUBCOMMAND\]/autocert.sh (certificates|certonly|delete|enhance|renew|revoke)/';
    exit 1;
} > /dev/stderr

# Check for Certbot Subcommand
SUBCOMMAND="$1";
case $SUBCOMMAND in
    ('certificates'|'certonly'|'delete'|'enhance'|'renew'|'revoke') shift;;
    (*) invalid_usage;;
esac

# Parse Options
CERT_NAME='';
DOMAINS='';
EMAIL='';
KEY_TYPE='';
KEY_SIZE='';
OPTIONS='--agree-tos --expand --non-interactive --config-dir /config/data';

while [ "$1" != '' ]; do
    case "$1" in
        # Drop Duplicate Options
        '--agree-tos');;
        '--expand');;
        '--non-interactive'|'--noninteractive'|'-n')
            case "$2" in 'True'|'False') shift; esac;;
        
        # Drop all execution path changes
        '--cert-path') shift;;
        '--key-path') shift;;
        '--fullchain-path') shift;;
        '--chain-path') shift;;
        '--config-dir') shift;;
        '--work-dir') shift;;
        '--logs-dir') shift;;
        '--server') shift;;
        '--config'|'-c') shift;;
        
        # User Defined Options
        '--key-type')
            shift;
            KEY_TYPE="$1";;
        '--rsa-key-size')
            shift;
            KEY_SIZE="$1";;
        '--cert-name')
            shift;
            CERT_NAME="$1";;
        '--email'|'-m')
            shift;
            EMAIL="$1";;
        '--domain'|'--domains'|'-d')
            shift;
            if [ ! "$DOMAINS" ]; then
                DOMAINS="$1";
            else
                DOMAINS="$DOMAINS,$1";
            fi;;
        *)
            OPTIONS="$OPTIONS $1";;
    esac;
    shift;
done

# Set Certificate Name and Domains
if [ -n "$DOMAINS" ]; then
    if [ ! "$CERT_NAME" ]; then
        CERT_NAME=$(echo $DOMAINS | sed 's/,.*//');
    fi
    OPTIONS="$OPTIONS --domains $DOMAINS";
fi

if [ -n "$CERT_NAME" ]; then
    OPTIONS="$OPTIONS --cert-name $CERT_NAME";
fi

# Add Creation Options
if [ "$SUBCOMMAND" = 'certonly' -o "$SUBCOMMAND" = 'enhance' -o "$SUBCOMMAND" = 'renew' ]; then
    OPTIONS="$OPTIONS --dns-luadns --dns-luadns-credentials /config/luadns.ini";

    if [ -n "$EMAIL" ]; then
        OPTIONS="$OPTIONS --email $EMAIL";
    else
        OPTIONS="$OPTIONS --email $DEFAULT_EMAIL";
    fi

    if [ -n "$KEY_TYPE" ]; then
        OPTIONS="$OPTIONS --key-type $KEY_TYPE";
    else
        OPTIONS="$OPTIONS --key-type rsa";
    fi

    if [ "$KEY_TYPE" = 'rsa' -a -n "$KEY_SIZE" ]; then
        OPTIONS="$OPTIONS --rsa-key-size $KEY_SIZE";
    else
        OPTIONS="$OPTIONS --rsa-key-size 4096";
    fi
fi

# Log Operation
echo "$0: Performing operation: certbot $SUBCOMMAND $OPTIONS";

# Execute Operation
certbot $SUBCOMMAND $OPTIONS;

# Process Status
STATUS=$?
if [ "$STATUS" -eq 0 ]; then
    echo "$0: Operation Success on $SUBCOMMAND";
else
    echo "$0: Operation Error on $SUBCOMMAND" > /dev/stderr;
    exit $STATUS;
fi

# Place Certificate Copies in /cert directory.
if [ "$SUBCOMMAND" = 'certonly' -o "$SUBCOMMAND" = 'enhance' -o "$SUBCOMMAND" = 'renew' ]; then
    echo "$0: Placing Existing Certificates in /config/cert directory";
    CERT_PATH="/config/data/live/$CERT_NAME";
    SAVE_PATH="/config/cert/$CERT_NAME";
    if [ -d "$CERT_PATH" ]; then
        [ -d "$SAVE_PATH" ] || mkdir -p "$SAVE_PATH";
        find "$CERT_PATH" -type l -exec cp {} "$SAVE_PATH" \;;
    fi
fi
