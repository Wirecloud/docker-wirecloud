#!/bin/bash

sed -i "s/SECRET_KEY = 'TOCHANGE_SECRET_KEY'/SECRET_KEY = '$(python -c "from django.utils.crypto import get_random_string; import re; print(re.escape(get_random_string(50, 'abcdefghijklmnopqrstuvwxyz0123456789%^&*(-_=+)')))")'/g" /opt/wirecloud_instance/wirecloud_instance/settings.py

# Check if there are any pending migration
python manage.py migrate --fake-initial

# Collect static files so we take into account custom themes and configurations
python manage.py collectstatic --noinput

su wirecloud -c "python manage.py populate"

# Start apache processes in foreground
/usr/sbin/apache2ctl graceful-stop
rm -f /var/run/apache2/apache2.pid
exec /usr/sbin/apache2ctl -D FOREGROUND
