# Autocert
A Docker container that helps manage SSL certificates by providing a Unix socket for certbot commands and wrapping each command with certbot authentication options and the luadns plugin.

## Container Summary
The Dockerfile pulls from `alpine:latest`, copies a few scripts scripts, and installs dependencies for certbot & certbot's luadns plugin used for DNS authentication.

Certbot attempts to renew all existing certificates found within the `/config/data` directory every 6 hours (or 4 times/day) using cron.

Certificates can be requested using the `autocert.sh` wrapper found within the container.
`autocert.sh` can also be executed via commands sent through the Unix socket `/config/cert/autocert.sock`. Giving other containers access to the `cert` directory will allow containers to generate and view certificates without directly accessing the DNS credential file.

The wrapper executes certbot in non-interactive mode, accepts all ACME Subscriber Agreements, and adds other options to enable Luadns authentication. All certbot options that alter the execution path of certbot will be dropped by default. Otherwise `autocert.sh` will forward any other certbot option flag.

## Container Configuration
There are a few variables that may need to be set in order for autocert to execute properly.
```dockerfile
ENV DOMAINS="example.com"
ENV EMAIL="email@example.com"
VOLUME "/config"
```
 - `DOMAINS` - [OPTIONAL] domains to request upon startup.
   - Comma-delineated domains will create a single certificate
   - Space-delineated domains create separate certificates.
 - `EMAIL` - [OPTIONAL] an email for certbot to use by default and for startup.
 - `/config` - the folder path for configuration within the container:
   - `cert/` contains hard copies of SSL certificates from `data/live`.
   - `data/` contain's certbot's previous work & archieves.
   - `luadns.ini` text file of luands email & API token.
  
It is highly recommended that one map the configuration directory when running the container; this will save certbot's previous work in the event of failure. In doing so, we decrease the chances of ever reaching the request rate limit for let's encrypt.

Enviroment variables should be set prior to testing this container. 
`example.com` is a reserved TLD and will be automatically rejected by certbot.

## Container Execution
```bash
docker run -e EMAIL='email@example.com' -v /config/:/config/ camcamfresh/autocert
```

## Autocert Execution
This wrapper works with most preexisting commands. Just replace `certbot` with `autocert.sh` and remove any preexisting authentication options.

General Exection
```sh
autocert.sh certonly -d 'example.com' -d '*.example.com' --cert-name 'wildcard_example.com'
```

Socket Execution
```sh
echo "autocert.sh certonly -d 'example.com' -d '*.example.com'" | socat unix-client:autocert.sock -;
echo "autocert.sh certonly -d 'example.com' -d '*.example.com'" | socat unix-client:autocert.sock stdin;
echo "autocert.sh certonly -d 'example.com' -d '*.example.com'" | nc -U autocert.sock;
```

Using this code requires the use of LuaDNS as a DNS provider. However it can quickly be changed to another DNS provider by forking the code and changing the dns-plugin to another supported DNS provider (see Certbot's website for available providers).
