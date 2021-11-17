ARG PYTHON_VERSION=3.6

ARG GITHUB_ACCOUNT=Wirecloud
ARG GITHUB_REPOSITORY=wirecloud
ARG SOURCE_BRANCH=develop



FROM python:${PYTHON_VERSION} AS builder

ARG GITHUB_ACCOUNT
ARG GITHUB_REPOSITORY
ARG SOURCE_BRANCH

# Build WireCloud wheel
RUN git clone -b "${SOURCE_BRANCH}" --depth=1  --single-branch https://github.com/"${GITHUB_ACCOUNT}"/"${GITHUB_REPOSITORY}".git && \
    apt-get update && apt-get install -y gettext && \
    pip install "django<=2.3" && \
    cd "${GITHUB_REPOSITORY}"/src && \
    python setup.py bdist_wheel



FROM python:${PYTHON_VERSION}-slim

ARG GITHUB_ACCOUNT
ARG GITHUB_REPOSITORY
ARG SOURCE_BRANCH

# Copying Build time arguments to environment variables so they are persisted at run time and can be 
# inspected within a running container.
# see: https://vsupalov.com/docker-build-time-env-values/  for a deeper explanation.

ENV GITHUB_ACCOUNT=${GITHUB_ACCOUNT} \
    GITHUB_REPOSITORY=${GITHUB_REPOSITORY} \
    DEFAULT_THEME=wirecloud.defaulttheme \
    FORWARDED_ALLOW_IPS=* \
    DB_PORT=5432 \
    LOGLEVEL=info \
    LOGFORMAT=plain \
    WORKERS=2 \
    THREADS=8

# Install WireCloud & dependencies
COPY --from=builder ${GITHUB_REPOSITORY}/src/dist /dist
COPY ./docker-entrypoint.sh /
COPY ./manage.py /usr/local/bin/

RUN apt-get update && \
    apt-get install -y --no-install-recommends libmemcached-dev libpcre3-dev gosu gcc ca-certificates curl && \
    pip install --no-cache-dir social-auth-app-django "gunicorn==19.3.0" "psycopg2-binary<2.9" pylibmc pysolr "elasticsearch==2.4.1" && \
    pip install --no-cache-dir /dist/*.whl && \
    rm -rf /dist && \
    adduser --system --group --shell /bin/bash wirecloud && \
    pip install --no-cache-dir "channels<2.3" "channels-redis" "wirecloud-keycloak>=0.3.0" && \
    mkdir -p /opt/wirecloud_instance /var/www/static && \
    cd /opt && \
    wirecloud-admin startproject wirecloud_instance wirecloud_instance && \
    chown -R wirecloud:wirecloud wirecloud_instance /var/www/static && \
    chmod a+x wirecloud_instance/manage.py  && \
    chmod a+x /docker-entrypoint.sh && \
    apt-get remove -y gcc libmemcached-dev --autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY ./settings.py ./urls.py /opt/wirecloud_instance/wirecloud_instance/
COPY ./glogger.py /usr/local/lib/python3.6/site-packages/wirecloud/

WORKDIR /opt/wirecloud_instance

VOLUME /var/www/static
VOLUME /opt/wirecloud_instance/data

EXPOSE 8000

HEALTHCHECK --interval=5s \
    --start-period=120s \
	CMD curl --fail http://localhost:8000/api/features || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["gunicorn"]
