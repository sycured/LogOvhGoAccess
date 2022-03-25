FROM alpine as base

COPY install-s6.sh /tmp/install-s6.sh

RUN mkdir -p /var/www \
    && apk add --no-cache bash goaccess unit wget \
    && chown -R unit:unit /var/www \
    && ln -sf /dev/stdout /var/log/unit.log \
    && ln -sf /dev/stdout /var/log/access.log \
    && rm /tmp/install-s6.sh

FROM base

COPY service_crond /etc/s6-overlay/s6-rc.d/cron/run

COPY service_unitd /etc/s6-overlay/s6-rc.d/nginx/run

RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/cron/type \
    && echo "longrun" > /etc/s6-overlay/s6-rc.d/nginx/type \
    && echo "de" > /etc/s6-overlay/s6-rc.d/nginx/dependencies \
    && mkdir /etc/s6-overlay/s6-rc.d/de \
    && echo "oneshot" > /etc/s6-overlay/s6-rc.d/de/type \
    && echo "exec bash -c '/usr/local/bin/docker-entrypoint.sh'" > /etc/s6-overlay/s6-rc.d/de/up \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/nginx \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/cron

