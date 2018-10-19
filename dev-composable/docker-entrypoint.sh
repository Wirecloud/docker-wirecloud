#!/bin/bash

# Wait DB to be accepting requests
exec 8<>/dev/tcp/${DB_HOST}/5432
DB_STATUS=$?

i=0

while [[ ${DB_STATUS} -ne 0 && ${i} -lt 50 ]]; do
    sleep 5
    exec 8<>/dev/tcp/${DB_HOST}/${DB_PORT}
    DB_STATUS=$?

    i=${i}+1
done

# allow the container to be started with `--user`
if [ "$(id -u)" = '0' ]; then
	chown -R wirecloud .
	chown -R wirecloud /var/www/static
fi

# Real entry point
case "$1" in
    initdb)
        manage.py migrate --fake-initial
        manage.py populate
        ;;
    createdefaultsuperuser)
        echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | manage.py shell > /dev/null
        ;;
    createsuperuser)
        manage.py createsuperuser
        ;;
    *)
        manage.py collectstatic --noinput
        manage.py migrate --fake-initial
        manage.py populate

        gosu wirecloud /usr/local/bin/gunicorn wirecloud_instance.wsgi:application --forwarded-allow-ips "${FORWARDED_ALLOW_IPS}" -w 2 -b :8000
        ;;
esac
