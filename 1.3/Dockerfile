FROM python:3.6-stretch

MAINTAINER WireCloud Team <wirecloud@conwet.com>

ENV DEFAULT_THEME=wirecloud.defaulttheme
ENV FORWARDED_ALLOW_IPS=*
ENV DB_HOST=
ENV DB_PORT=5432
ENV LOGLEVEL=info

RUN apt-get update && \
    apt-get install -y libmemcached-dev gosu && \
    pip install --no-cache-dir social-auth-app-django "gunicorn==19.3.0" "psycopg2==2.6" pylibmc pysolr "elasticsearch==2.4.1" && \
    rm -rf /var/lib/apt/lists/* && \
    gosu nobody true

# Install WireCloud & dependencies
RUN pip install --no-cache-dir "wirecloud<1.4"

COPY ./docker-entrypoint.sh /
COPY ./manage.py /usr/local/bin/

RUN adduser --system --group --shell /bin/bash wirecloud && \
    pip install --no-cache-dir channels asgi_ipc asgi_redis asgi_rabbitmq && \
    mkdir -p /opt/wirecloud_instance /var/www/static && \
    cd /opt && \
    wirecloud-admin startproject wirecloud_instance wirecloud_instance && \
    chown -R wirecloud:wirecloud wirecloud_instance /var/www/static && \
    chmod a+x wirecloud_instance/manage.py

COPY ./settings.py ./urls.py /opt/wirecloud_instance/wirecloud_instance/

WORKDIR /opt/wirecloud_instance

VOLUME /var/www/static
VOLUME /opt/wirecloud_instance/data

EXPOSE 8000

HEALTHCHECK --interval=3s \
    --start-period=40s \
	CMD curl --fail http://localhost:8000/api/features || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
