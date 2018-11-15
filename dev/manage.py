#!/usr/bin/env bash
cd /opt/wirecloud_instance
if [ "$(id -u)" = '1042' ]; then
    python manage.py $@
else
    gosu wirecloud python manage.py $@
fi
