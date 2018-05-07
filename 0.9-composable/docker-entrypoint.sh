#!/bin/bash

# Wait DB to be accepting requests
exec 8<>/dev/tcp/postgres/5432
DB_STATUS=$?

i=0

while [[ ${DB_STATUS} -ne 0 && ${i} -lt 50 ]]; do
    sleep 5
    exec 8<>/dev/tcp/postgres/5432
    DB_STATUS=$?

    i=${i}+1
done

# Check if we have to init wirecloud configuration
if [ ! -f /opt/wirecloud_instance/wirecloud_instance/settings.py ]; then

    cd /opt

    # Use the target_directory parameter to indicate that we want to use that
    # directory even if it exit
    wirecloud-admin startproject wirecloud_instance wirecloud_instance
    chmod a+x wirecloud_instance/manage.py

    cd /opt/wirecloud_instance

    sed -i "s/'ENGINE': 'django.db.backends.'/'ENGINE': 'django.db.backends.postgresql_psycopg2'/g" wirecloud_instance/settings.py; \
    sed -i "s/'NAME': ''/'NAME': 'postgres'/g" wirecloud_instance/settings.py; \
    sed -i "s/'USER': ''/'USER': 'postgres'/g" wirecloud_instance/settings.py; \
    sed -i "s/'PASSWORD': ''/'PASSWORD': 'postgres'/g" wirecloud_instance/settings.py; \
    sed -i "s/'HOST': ''/'HOST': 'postgres'/g" wirecloud_instance/settings.py; \
    sed -i "s/'PORT': ''/'PORT': '5432'/g" wirecloud_instance/settings.py; \
    sed -i "s/SECRET_KEY = '[^']\+'/SECRET_KEY = '$(python -c "from django.utils.crypto import get_random_string; import re; print(re.escape(get_random_string(50, 'abcdefghijklmnopqrstuvwxyz0123456789%^&*(-_=+)')))")'/g" wirecloud_instance/settings.py; \
    sed -i "s/STATIC_ROOT = path.join(BASEDIR, '..\/static')/STATIC_ROOT = '\/var\/www\/static'/g" wirecloud_instance/settings.py

    python manage.py collectstatic --noinput; \

    python manage.py migrate --fake-initial
    python manage.py populate
fi

cd /opt/wirecloud_instance

# Real entry point
case "$1" in
    initdb)
        python manage.py migrate --fake-initial
        ;;
    createdefaultsuperuser)
        echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell > /dev/null
        ;;
    createsuperuser)
        python manage.py createsuperuser
        ;;
    *)
        /usr/local/bin/gunicorn wirecloud_instance.wsgi:application -w 2 -b :8000
        ;;
esac
