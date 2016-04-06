FROM python:2

MAINTAINER WireCloud Team <wirecloud@conwet.com>

RUN pip install "wirecloud<0.10.0" "gunicorn==19.3.0" "psycopg2==2.6"

WORKDIR /opt

RUN adduser --system --group --shell /bin/bash wirecloud
RUN wirecloud-admin startproject wirecloud_instance

WORKDIR /opt/wirecloud_instance

RUN sed -i "s/'ENGINE': 'django.db.backends.'/'ENGINE': 'django.db.backends.postgresql_psycopg2'/g" wirecloud_instance/settings.py
RUN sed -i "s/'NAME': ''/'NAME': 'postgres'/g" wirecloud_instance/settings.py
RUN sed -i "s/'USER': ''/'USER': 'postgres'/g" wirecloud_instance/settings.py
RUN sed -i "s/'PASSWORD': ''/'PASSWORD': 'postgres'/g" wirecloud_instance/settings.py
RUN sed -i "s/'HOST': ''/'HOST': 'postgres'/g" wirecloud_instance/settings.py
RUN sed -i "s/'PORT': ''/'PORT': '5432'/g" wirecloud_instance/settings.py
RUN sed -i "s/SECRET_KEY = '[^']\+'/SECRET_KEY = 'TOCHANGE_SECRET_KEY'/g" wirecloud_instance/settings.py

RUN sed -i "s/STATIC_ROOT = path.join(BASEDIR, '..\/static')/STATIC_ROOT = '\/var\/www\/static'/g" wirecloud_instance/settings.py

RUN python manage.py collectstatic --noinput
#RUN python manage.py compress --force

# volumes must be created after running the collectstatic and compress commands
VOLUME /var/www/static
VOLUME /opt/wirecloud_instance

EXPOSE 8000

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
