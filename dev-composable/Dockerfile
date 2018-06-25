FROM python:3-stretch

MAINTAINER WireCloud Team <wirecloud@conwet.com>

ENV FORWARDED_ALLOW_IPS=*
ENV DB_HOST=postgres

RUN apt-get update && \
    apt-get install -y libmemcached-dev && \
    pip install --no-cache-dir social-auth-app-django "gunicorn==19.3.0" "psycopg2==2.6" pylibmc pysolr "elasticsearch==2.4.1" && \
    rm -rf /var/lib/apt/lists/*

# Install WireCloud & dependencies
RUN git clone --depth=1 https://github.com/Wirecloud/wirecloud.git && \
    cd wirecloud/src && \
    python setup.py bdist_wheel && \
    pip install --no-cache-dir dist/*.whl && \
    cd ../.. && \
    rm -rf wirecloud

RUN adduser --system --group --shell /bin/bash wirecloud && \
    pip install --no-cache-dir channels asgi_ipc asgi_redis asgi_rabbitmq && \
    mkdir -p /opt/wirecloud_instance /var/www/static && \
    chown wirecloud:wirecloud /opt/wirecloud_instance /var/www/static

WORKDIR /opt/wirecloud_instance

# volumes must be created after running the collectstatic command
VOLUME /var/www/static
VOLUME /opt/wirecloud_instance

EXPOSE 8000

COPY ./docker-entrypoint.sh /
COPY ./manage.py /usr/local/bin/
ENTRYPOINT ["/docker-entrypoint.sh"]
