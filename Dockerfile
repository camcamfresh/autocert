FROM alpine:latest

ENV DEFAULT_EMAIL="email@example.com"
VOLUME "/config"

COPY autocert.sh            /usr/sbin/autocert.sh
COPY entrypoint.sh          /entrypoint.sh

RUN chmod +x /entrypoint.sh /usr/sbin/autocert.sh &&\
    apk update &&\
    apk upgrade &&\
    apk add py3-pip gcc python3-dev musl-dev libffi-dev cargo openssl-dev socat &&\
    pip3 install -U pip certbot certbot-dns-luadns cryptography

CMD ["/entrypoint.sh"]
