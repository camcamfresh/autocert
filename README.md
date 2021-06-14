# Autocert
A Docker container that helps manage SSL certificates by providing a pipe for certbot commands and wrapping each command with certbot authentication options and the luadns plugin.

## Container Summary
The Dockerfile pulls from `alpine:latest`, copies necessary scripts, and installs the required dependencies for certbot & certbot's luadns plugin which is used for DNS authentication.

Certbot attempts to renew all existing certificates found within the /config/data directory every 6 hours (or 4 times/day) using cron.

Certificates can be requested using the `autocert.sh` wrapper found within the container.
`autocert.sh` can also be executed via commands sent through the pipe `/config/autocert.pipe`. Giving other containers access to `autocert.pipe` and `certs` within the `/config` directory will allow containers to generate and view certificates without directly accessing the DNS credential file.

The wrapper executes certbot in non-interactive mode, accepts all ACME Subscriber Agreements, and adds other options to enable Luadns authentication. All certbot options that alter the execution path of certbot will be dropped by default. Otherwise `autocert.sh` will forward any other certbot flag.

# Container Configuration
There are a few variables that must be set in order for autocert to execute properly.
```dockerfile
ENV EMAIL="email@example.com"
VOLUME "/config"
```

- EMAIL - an email for certbot to use by default.
- `/config` - the folder path for configuration within the container:
  - `certs/` contains hard copies of SSL certificates from `data/live`.
  - `data/` contain's certbot's previous work & archieves.
  - `luadns.ini` must have the domain's luands email & API token.
  
It is highly recommended that one map the configuration directory when running the container; this will save certbot's previous work in the event of failure. In doing so, we decrease the chances of ever reaching the request rate limit for let's encrypt.

Enviroment variables should be set prior to testing this container. 
`example.com` is a reserved TLD and will be automatically rejected by certbot.

# Container Execution
```bash
docker run -e EMAIL='email@example.com' -v /config/:/config/ camcamfresh/autocert
```

# Autocert Execution
This wrapper works with most preexisting commands. Just replace `certbot` with `autocert.sh` and remove any preexisting authentication options.

General Exection
```sh
autocert.sh certonly -d 'example.com' -d '*.example.com' --cert-name 'wildcard_example.com'
```

Piped Execution
```sh
echo "autocert.sh certonly -d 'example.com' -d '*.example.com'" > /config/autocert.pipe
```

Using this current code requires the use of LuaDNS as a DNS provider. However it can quickly be changed to another DNS provider by forking the code and changing the dns-plugin to another supported DNS provider (see Certbot's website for available providers).
