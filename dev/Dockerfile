FROM python:3.6-stretch

MAINTAINER WireCloud Team <wirecloud@conwet.com>

ENV DEFAULT_THEME=wirecloud.defaulttheme
ENV FORWARDED_ALLOW_IPS=*
ENV DB_PORT=5432

RUN apt-get update && \
    apt-get install -y libmemcached-dev && \
    pip install --no-cache-dir social-auth-app-django "gunicorn==19.3.0" "psycopg2==2.6" pylibmc pysolr "elasticsearch==2.4.1" && \
    rm -rf /var/lib/apt/lists/* && \
    \
    export dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.11/gosu-$dpkgArch" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.11/gosu-$dpkgArch.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    for server in $(shuf -e ha.pool.sks-keyservers.net \
                            hkp://p80.pool.sks-keyservers.net:80 \
                            keyserver.ubuntu.com \
                            hkp://keyserver.ubuntu.com:80 \
                            pgp.mit.edu) ; do \
        gpg --keyserver "$server" --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
    done && \
    #gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

# Install WireCloud & dependencies
RUN git clone --depth=1 https://github.com/Wirecloud/wirecloud.git && \
    pip install "django<=1.11" && \
    cd wirecloud/src && \
    python setup.py bdist_wheel && \
    pip install --no-cache-dir dist/*.whl && \
    cd ../.. && \
    rm -rf wirecloud

COPY ./docker-entrypoint.sh /
COPY ./manage.py /usr/local/bin/

RUN adduser --system --group --shell /bin/bash wirecloud && \
    pip install --no-cache-dir channels asgi_ipc asgi_redis asgi_rabbitmq && \
    mkdir -p /opt/wirecloud_instance /var/www/static && \
    cd /opt && \
    wirecloud-admin startproject wirecloud_instance wirecloud_instance && \
    chown -R wirecloud:wirecloud wirecloud_instance /var/www/static && \
    chmod a+x wirecloud_instance/manage.py

USER wirecloud

COPY ./settings.py ./urls.py /opt/wirecloud_instance/wirecloud_instance/

WORKDIR /opt/wirecloud_instance

# volumes must be created after running the collectstatic command
VOLUME /var/www/static
VOLUME /opt/wirecloud_instance/data

EXPOSE 8000

ENTRYPOINT ["/docker-entrypoint.sh"]
