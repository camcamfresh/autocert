FROM alpine:latest

ENV EMAIL='email@example.com'
VOLUME ["config"]

COPY autocert.sh      /usr/sbin/autocert.sh
COPY autocertPipe.sh  /usr/sbin/autocertPipe.sh
COPY entrypoint.sh    /entrypoint.sh

RUN chmod +x /entrypoint.sh /usr/sbin/autocert*.sh &&\
    echo '*/5 * * * * autocert.sh renew' | crontab - &&\
    apk update &&\
    apk upgrade &&\
    apk add py3-pip gcc python3-dev musl-dev libffi-dev cargo openssl-dev &&\
    pip3 install -U pip certbot certbot-dns-luadns cryptography

CMD ["/entrypoint.sh"]
