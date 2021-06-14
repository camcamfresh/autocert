FROM alpine:latest

ENV EMAIL='email@example.com'
ENV CONFIG_DIR='/config'

VOLUME ["config"]

COPY autocert.sh      /usr/sbin/autocert.sh
COPY autocertPipe.sh  /usr/sbin/autocertPipe.sh
COPY entrypoint.sh    /entrypoint.sh

CMD ["sh", "/entrypoint.sh"]
