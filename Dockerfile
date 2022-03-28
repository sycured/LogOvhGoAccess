FROM alpine as base

COPY geoip_update.sh /etc/periodic/weekly/geoip_update.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY install-s6.sh /tmp/install-s6.sh
RUN mkdir -p /var/www/logs/ \
    && apk add --no-cache bash coreutils curl gawk openssl unit wget goaccess \
    && chown -R unit:unit /var/www \
    && ln -sf /dev/stdout /var/log/unit.log \
    && ln -sf /dev/stdout /var/log/access.log \
    && /tmp/install-s6.sh \
    && rm /tmp/install-s6.sh

FROM base
COPY service_crond /etc/s6-overlay/s6-rc.d/cron/run
COPY service_unitd /etc/s6-overlay/s6-rc.d/nginx/run
COPY config.json /docker-entrypoint.d/

RUN chmod +x /etc/periodic/weekly/geoip_update.sh \
    && echo "longrun" > /etc/s6-overlay/s6-rc.d/cron/type \
    && echo "longrun" > /etc/s6-overlay/s6-rc.d/nginx/type \
    && echo "de" > /etc/s6-overlay/s6-rc.d/nginx/dependencies \
    && mkdir /etc/s6-overlay/s6-rc.d/de \
    && echo "oneshot" > /etc/s6-overlay/s6-rc.d/de/type \
    && echo "exec bash -c '/usr/local/bin/docker-entrypoint.sh'" > /etc/s6-overlay/s6-rc.d/de/up \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/nginx \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/cron


COPY ./script/script_immediate.sh /etc/periodic/15min/
COPY ./script/script_daily.sh /etc/periodic/daily/
COPY boot.sh set_access_log.sh /docker-entrypoint.d/

EXPOSE 8000
ENTRYPOINT ["/init"]