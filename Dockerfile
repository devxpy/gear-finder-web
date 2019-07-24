FROM abiosoft/caddy as caddy
FROM python

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY --from=caddy /usr/bin/caddy .
COPY . /usr/src/app

CMD /usr/src/app/scripts/run-prod.sh
