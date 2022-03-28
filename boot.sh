#!/command/with-contenv bash
/etc/periodic/weekly/geoip_update.sh 0
/etc/periodic/15min/script_immediate.sh
/etc/periodic/daily/script_daily.sh