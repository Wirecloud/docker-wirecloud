FROM python:3-stretch

MAINTAINER WireCloud Team <wirecloud@conwet.com>

RUN apt-get update; \
    apt-get install -y libmemcached-dev; \
    pip install social-auth-app-django "gunicorn==19.3.0" "psycopg2==2.6" pylibmc pysolr "elasticsearch==2.4.1"

# Install WireCloud & dependencies
RUN git clone --depth=1 https://github.com/Wirecloud/wirecloud.git; \
    cd wirecloud/src; \
    python setup.py bdist_wheel; \
    pip install dist/*.whl; \
    cd ../.. \
    rm -rf wirecloud

RUN pip install channels asgi_ipc asgi_redis asgi_rabbitmq; \
    mkdir /opt/wirecloud_instance

WORKDIR /opt/wirecloud_instance

# volumes must be created after running the collectstatic command
VOLUME /var/www/static
VOLUME /opt/wirecloud_instance

EXPOSE 8000

COPY ./docker-entrypoint.sh /
COPY ./manage.py /usr/local/bin/
ENTRYPOINT ["/docker-entrypoint.sh"]
