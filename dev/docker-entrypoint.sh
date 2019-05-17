#!/bin/bash

set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'DB_PASSWORD' 'example'
# (will allow for "$DB_PASSWORD_FILE" to fill in the value of
#  "$DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

file_env 'DB_PASSWORD' 'postgres'
file_env 'DB_USERNAME' 'postgres'
file_env 'SOCIAL_AUTH_FIWARE_KEY'
file_env 'SOCIAL_AUTH_FIWARE_SECRET'

# allow the container to be started with `--user`
if [ "$(id -u)" = '0' ]; then
	chown -R wirecloud data
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

        # allow the container to be started with `--user`
        if [ "$(id -u)" = '0' ]; then
            exec gosu wirecloud /usr/local/bin/gunicorn wirecloud_instance.wsgi:application \
                --forwarded-allow-ips "${FORWARDED_ALLOW_IPS}" \
                --workers 2 \
                --bind 0.0.0.0:8000 \
                --log-file - \
                --log-level ${LOGLEVEL}
        else
            exec /usr/local/bin/gunicorn wirecloud_instance.wsgi:application \
                --forwarded-allow-ips "${FORWARDED_ALLOW_IPS}" \
                --workers 2 \
                --bind 0.0.0.0:8000 \
                --log-file - \
                --log-level ${LOGLEVEL}
        fi
        ;;
esac
