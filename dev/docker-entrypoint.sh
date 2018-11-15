#!/bin/bash

set -e

echo "In docker-entrypoint"
echo "We are running a user: $(id -u)"
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
		    echo "Default Case:"
				echo "Current User: $(id -u)"
        manage.py collectstatic --noinput
        manage.py migrate --fake-initial
        manage.py populate
				echo "About to start"
				if [ "$(id -u)" = '1042' ]; then
        	wirecloud /usr/local/bin/gunicorn wirecloud_instance.wsgi:application --forwarded-allow-ips "${FORWARDED_ALLOW_IPS}" -w 2 -b :8000
				else
					gosu wirecloud /usr/local/bin/gunicorn wirecloud_instance.wsgi:application --forwarded-allow-ips "${FORWARDED_ALLOW_IPS}" -w 2 -b :8000
				fi
				;;
esac
