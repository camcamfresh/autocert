#!/bin/sh
# Author : Cameron S.
# License: https://www.gnu.org/licenses/gpl-3.0.en.html

invalid_usage() {
    echo "Invalid Usage: This is a daemon wrapper around certbot that adds authentication.";
    certbot -h | sed "s/certbot \[SUBCOMMAND\]/autocert.sh (certonly|delete|enhance|renew|revoke)/";
    exit 1;
} > /dev/stderr

# Log Request
echo "$0: Request received ($*)";

# Check for Certbot Subcommand
SUBCOMMAND="$1";
case $SUBCOMMAND in
    ('certonly'|'delete'|'enhance'|'renew'|'revoke') shift;;
    (*) invalid_usage;;
esac

# Parse Options
CERT_NAME='';
DOMAINS='';
EMAIL="$EMAIL";
KEY_TYPE='rsa';
KEY_SIZE='4096';
OPTIONS='';

while [ "$1" != '' ]; do
    case "$1" in
        # Drop Potential Duplicate Options
        '--agree-tos');;
        '--expand');;
        '--non-interactive'|'--noninteractive'|'-n')
            case "$2" in 'True'|'False') shift; esac;;
        '--key-type')
            shift;
            KEY_TYPE="$1"
            [ "$KEY_TYPE" != 'rsa' ] && KEY_SIZE='';;
        '--rsa-key-size')
            shift;
            KEY_SIZE="$1";;

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
        
        # Add Other Options
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
            if [ ! "$OPTIONS" ]; then
                OPTIONS="$1";
            else
                OPTIONS="$OPTIONS $1";
            fi;;
    esac;
    shift;
done

# Set Certificate Name and Domains
if [ -n "$DOMAINS" ]; then
    if [ ! "$CERT_NAME" ]; then
        CERT_NAME=$(echo $DOMAINS | sed 's|(.*)(,.+)?|\1|');
    fi
    OPTIONS="$OPTIONS --domains $DOMAINS";
fi

if [ -n "$CERT_NAME" ]; then
    OPTIONS="$OPTIONS --cert-name $CERT_NAME";
fi

if [ -n "$EMAIL" ]; then
    OPTIONS="$OPTIONS --email $EMAIL";
fi

if [ -n "$KEY_TYPE" ]; then
    OPTIONS="$OPTIONS --key-type $KEY_TYPE";
fi

if [ -n "$KEY_SIZE" ]; then
    OPTIONS="$OPTIONS --rsa-key-size $KEY_SIZE";
fi

# Log Operation
echo "$0: Performing $SUBCOMMAND operation on $CERT_NAME for $DOMAINS with options $OPTIONS";

# Execute Operation
certbot "$SUBCOMMAND" \
    --agree-tos \
    --expand \
    --config-dir "/config/data" \
    --dns-luadns \
    --dns-luadns-credentials "/config/luadns.ini" \
    --non-interactive \
    $OPTIONS;

# Process Status
STATUS=$?
if [ "$STATUS" -eq 0 ]; then
    echo "$0: Successfully Executed $SUBCOMMAND on $CERT_NAME";
else
    echo "$0: An error occured executing $SUBCOMMAND on $CERT_NAME" > /dev/stderr;
    exit $STATUS;
fi

# Place Certificate Copies in /cert directory.
echo "$0: Placing Existing Certificates in /config/cert directory";

CERT_PATH="/config/data/live/$CERT_NAME";
SAVE_PATH="/config/cert/$CERT_NAME";
if [ -d "$CERT_PATH" ]; then
    [ -d "$SAVE_PATH" ] || mkdir -p "$SAVE_PATH";
    find "$CERT_PATH" -type l -exec cp {} "$SAVE_PATH" \;;
fi
