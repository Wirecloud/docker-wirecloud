#!/bin/bash

sed -i "s/SECRET_KEY = 'TOCHANGE_SECRET_KEY'/SECRET_KEY = '$(python -c "from django.utils.crypto import get_random_string; import re; print(re.escape(get_random_string(50, 'abcdefghijklmnopqrstuvwxyz0123456789%^&*(-_=+)')))")'/g" /opt/wirecloud_instance/wirecloud_instance/settings.py

case "$1" in
    initdb)
        python manage.py syncdb --migrate
        ;;
    *)
        /usr/local/bin/gunicorn wirecloud_instance.wsgi:application -w 2 -b :8000
        ;;
esac
