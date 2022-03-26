FROM alpine as base

COPY install-s6.sh /tmp/install-s6.sh

RUN mkdir -p /var/www \
    && apk add --no-cache bash curl gawk unit wget goaccess \
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
    && echo "exec bash -c '/usr/local/bin/docker-entrypoint.sh'" > /etc/s6-overlay/s6-rc.d/de/up

COPY config.json /docker-entrypoint.d/

COPY ./script/script_immediate.sh /etc/periodic/15min/

COPY ./script/script_daily.sh /etc/periodic/daily/

RUN chmod +x /etc/periodic/15min/script_immediate.sh \
    && chmod +x /etc/periodic/daily/script_daily.sh

COPY boot.sh set_access_log.sh /docker-entrypoint.d/

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/init"]