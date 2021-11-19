ARG PYTHON_VERSION=3.8
FROM python:${PYTHON_VERSION}-slim

ENV GITHUB_ACCOUNT=${GITHUB_ACCOUNT} \
    GITHUB_REPOSITORY=${GITHUB_REPOSITORY} \
    DEFAULT_THEME=wirecloud.defaulttheme \
    FORWARDED_ALLOW_IPS=* \
    DB_PORT=5432 \
    LOGLEVEL=info

# Install WireCloud & dependencies
COPY ./docker-entrypoint.sh /
COPY ./manage.py /usr/local/bin/

RUN apt update && \
    apt install -y --no-install-recommends libmemcached-dev libpcre3-dev gosu gcc ca-certificates curl && \
    pip install --no-cache-dir social-auth-app-django "gunicorn==19.3.0" "psycopg2-binary<2.9" pylibmc pysolr "elasticsearch==2.4.1" && \
    pip install --no-cache-dir "wirecloud<1.5" && \
    adduser --system --group --shell /bin/bash wirecloud && \
    pip install --no-cache-dir "channels<2.3" "channels-redis" "channels-rabbitmq" "wirecloud-keycloak>=0.3.0" && \
    mkdir -p /opt/wirecloud_instance /var/www/static && \
    cd /opt && \
    wirecloud-admin startproject wirecloud_instance wirecloud_instance && \
    chown -R wirecloud:wirecloud wirecloud_instance /var/www/static && \
    chmod a+x wirecloud_instance/manage.py  && \
    chmod a+x /docker-entrypoint.sh && \
    apt-get remove -y gcc libmemcached-dev --autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY ./settings.py ./urls.py /opt/wirecloud_instance/wirecloud_instance/

WORKDIR /opt/wirecloud_instance

VOLUME /var/www/static
VOLUME /opt/wirecloud_instance/data

HEALTHCHECK --interval=5s \
    --start-period=120s \
	CMD curl --fail http://localhost:8000/api/features || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
