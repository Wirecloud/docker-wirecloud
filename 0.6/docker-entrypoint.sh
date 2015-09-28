#!/bin/bash
# python manage.py migrate                  # Apply database migrations
# python manage.py collectstatic --noinput  # Collect static files

sed -i "s/SECRET_KEY = 'TOCHANGE_SECRET_KEY'/SECRET_KEY = '$(python -c "from django.utils.crypto import get_random_string; import re; print(re.escape(get_random_string(50, 'abcdefghijklmnopqrstuvwxyz0123456789%^&*(-_=+)')))")'/g" /opt/wirecloud_instance/wirecloud_instance/settings.py

# Start apache processes in foreground
/usr/sbin/apache2ctl graceful-stop
exec /usr/sbin/apache2ctl -D FOREGROUND
