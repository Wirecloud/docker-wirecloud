# Supported tags and respective `Dockerfile` links #

- [`1.3`, `1.3.1`, `FIWARE_7.7.1`](https://github.com/Wirecloud/docker-wirecloud/blob/master/1.3/Dockerfile)
- [`1.2`, `latest`](https://github.com/Wirecloud/docker-wirecloud/blob/master/1.2/Dockerfile)
- [`dev`](https://github.com/Wirecloud/docker-wirecloud/blob/master/dev/Dockerfile)


# What is WireCloud?

[![](https://nexus.lab.fiware.org/repository/raw/public/badges/chapters/visualization.svg)](https://www.fiware.org/developers/catalogue/)
[![Support badge](https://img.shields.io/badge/tag-fiware--wirecloud-orange.svg?logo=stackoverflow)](https://stackoverflow.com/questions/tagged/fiware-wirecloud)

WireCloud builds on cutting-edge end-user development, RIA and semantic technologies to offer a next-generation end-user centred web application mashup platform aimed at leveraging the long tail of the Internet of Services. WireCloud builds on cutting-edge end-user (software) development, RIA and semantic technologies to offer a next-generation end-user centred web application mashup platform aimed at allowing end users without programming skills to easily create web applications and dashboards/cockpits (e.g. to visualize their data of interest or to control their domotized home or environment). Web application mashups integrate heterogeneous data, application logic, and UI components (widgets) sourced from the Web to create new coherent and value-adding composite applications. They are targeted at leveraging the "long tail" of the Web of Services (a.k.a. the Programmable Web) by exploiting rapid development, DIY, and shareability. They typically serve a specific situational (i.e. immediate, short-lived, customized) need, frequently with high potential for reuse. Is this "situational" character which precludes them to be offered as 'off-the-shelf' functionality by solution providers, and therefore creates the need for a tool like WireCloud

WireCloud is part of [FIWARE](https://www.fiware.org/). Check it out in the [Catalogue](https://www.fiware.org/developers/catalogue/)

[![WireCloud's logo](https://raw.githubusercontent.com/Wirecloud/docker-wirecloud/master/logo.png)](https://github.com/Wirecloud/wirecloud)


# How to use this image

```
$ docker run --name some-wirecloud -p 80:8000 -e DEBUG=True -d fiware/wirecloud
```

The following environment variables are also honored for configuring your WireCloud instance:

- `-e DEBUG=...` (defaults to "False", use "True" for running WireCloud in debug
    mode. Debug mode should be enabled for running WireCloud in standalone mode)
- `-e LOGLEVEL=...` (defaults to "INFO")
- `-e ALLOWED_HOSTS=...` (defaults to "*", whitespace whitespace-separated list
    of allowed hosts. See [Django documentation][ALLOWED_HOSTS] for more
    details)
- `-e DEFAULT_LANGUAGE=...` (defaults to "browser", see
    [documentation][DEFAULT_LANGUAGE] for more details)
- `-e DEFAULT_THEME=...` (defaults to "wirecloud.defaulttheme")
- `-e DB_HOST=...` (defaults to nothing, provide a host value to connect this
    image with a DB server)
- `-e DB_NAME=...` (defaults to "postgres")
- `-e DB_USERNAME=...` (defaults to "postgres")
- `-e DB_PASSWORD=...` (defaults to "postgres")
- `-e DB_PORT=...` (defaults to "5432")
- `-e FORWARDED_ALLOW_IPS=...` (defaults to "*", set this to provide a list of
    trusted reverse proxies)
- `-e ELASTICSEARCH2_URL=...` (defaults to nothing, leave it empty to use Whoosh
    instead).
- `-e LANGUAGE_CODE=...` (defaults to "en-gb", See [django
    documentation][LANGUAGE_CODE] for more details)
- `-e MEMCACHED_LOCATION=...` (defaults to nothing, leave it empty to disable
    memcached support)
- `-e FIWARE_IDM_SERVER=...` (defaults to nothing, leave it empty for
    authenticating users using the credentials stored on the WireCloud
    database.)
- `-e FIWARE_IDM_PUBLIC_URL=...` (defaults to nothing, leave it empty for using
    the `FIWARE_IDM_SERVER` configuration for building the url when redirecting
    the browser to the IdM portal)
- `-e SOCIAL_AUTH_FIWARE_KEY=...` (defaults to nothing)
- `-e SOCIAL_AUTH_FIWARE_SECRET=...` (defaults to nothing)
- `-e KEYCLOAK_IDM_SERVER=...` (defaults to nothing, leave it empty for
    authenticating users using the credentials stored on the WireCloud
    database.)
- `-e KEYCLOAK_REALM=...` (default to nothing, realm to use for connecting with
   keycloak)
- `-e KEYCLOAK_KEY=...` (default to nothing)
- `-e KEYCLOAK_GLOBAL_ROLE=...` (default to "False")
- `-e SOCIAL_AUTH_KEYCLOAK_KEY=...` (defaults to nothing)
- `-e SOCIAL_AUTH_KEYCLOAK_SECRET=...` (defaults to nothing)
- `-e HTTPS_VERIFY=...` (True, False or path to a certificate bundle, default to
   "/etc/ssl/certs/ca-certificates.crt")
- `-e ADMIN_URL_PATH=...` (default to "^admin/", regexp for the administration path)

In addition to those environment variables, this docker image also allows you to
configure the following Django settings using environment variables with the
same name: `CACHE_MIDDLEWARE_KEY_PREFIX`, `CSRF_COOKIE_AGE`,
`CSRF_COOKIE_HTTPONLY`, `CSRF_COOKIE_NAME`, `CSRF_COOKIE_SECURE`,
`DEFAULT_FROM_EMAIL`, `EMAIL_HOST`, `EMAIL_HOST_PASSWORD`, `EMAIL_PORT`,
`EMAIL_HOST_USER`, `EMAIL_USE_SSL`, `EMAIL_USE_TLS`, `FORCE_SCRIPT_NAME`,
`LOGOUT_REDIRECT_URL`, `SECRET_KEY`, `SESSION_COOKIE_AGE`,
`SESSION_COOKIE_NAME`, `SESSION_COOKIE_HTTPONLY` and `SESSION_COOKIE_SECURE`.
See [Django documentation][DJANGO_SETTINGS] for more details.

When running WireCloud with TLS behind a reverse proxy such as Apache/NGINX
which is responsible for doing TLS termination, be sure to set
the `X-Forwarded-Proto`, `X-Forwarded-Host` and `X-Forwarded-Port` headers
appropriately.


[DJANGO_SETTINGS]: https://docs.djangoproject.com/en/2.1/ref/settings/
[ALLOWED_HOSTS]: https://docs.djangoproject.com/en/2.1/ref/settings/#allowed-hosts
[DEFAULT_LANGUAGE]: https://wirecloud.readthedocs.io/en/stable/installation_guide/#default_language
[LANGUAGE_CODE]: https://docs.djangoproject.com/en/2.1/ref/settings/#language-code


### Docker Secrets

As an alternative to passing sensitive information via environment variables, `_FILE` may be appended to some sensitive
environment variables, causing the initialization script to load the values for those variables from files present in
the container. In particular, this can be used to load passwords from Docker secrets stored in
`/run/secrets/<secret_name>` files. For example:

```console
docker run --name wirecloud -e DB_PASSWORD_FILE=/run/secrets/password -d fiware/wirecloud
```

Currently, this `_FILE` suffix is supported for:

-  `EMAIL_HOST_PASSWORD`
-  `KEYCLOAK_KEY`
-  `LOGOUT_REDIRECT_URL`
-  `SECRET_KEY`
-  `SOCIAL_AUTH_FIWARE_KEY`
-  `SOCIAL_AUTH_FIWARE_SECRET`
-  `SOCIAL_AUTH_KEYCLOAK_KEY`
-  `SOCIAL_AUTH_KEYCLOAK_SECRET`


## Running manage.py commands

You can run any available `manage.py` command by using `docker exec -ti some-wirecloud manage.py ...`. For example, you can create superusers/administrators by running the following command:

```
$ docker exec -ti some-wirecloud manage.py createsuperuser
Username (leave blank to use 'root'): admin
Email address: ${youremail}
Password: ${yourpassword}
Password (again): ${yourpassword}
Superuser created successfully.
```

Regarding commands using the filesystem, take into account that those commands will be executed inside the container and thus the filesystem will be the one used by the container. The `manage.py` script will not check if those commands make changes outside the provided volumes. Anyway, they can be used without any problem. For example, static files can be collected using the following command:

```
$ docker exec -ti some-wirecloud manage.py collectstatic
```

Use `docker exec -ti some-wirecloud manage.py --help` for getting the list of available commands.


## ... via `docker stack deploy` or `docker-compose`

Example `docker-compose.yml` for WireCloud:

```yaml
version: "3"

services:

    nginx:
        restart: always
        image: nginx
        ports:
            - 80:80
        volumes:
            - ./nginx.conf:/etc/nginx/nginx.conf:ro
            - ./wirecloud-static:/var/www/static:ro
        depends_on:
            - wirecloud


    postgres:
        restart: always
        image: postgres
        environment:
            - POSTGRES_PASSWORD=wirepass   # Change this password!
        volumes:
            - ./postgres-data:/var/lib/postgresql/data


    elasticsearch:
        restart: always
        image: elasticsearch:2.4
        volumes:
            - ./elasticsearch-data:/usr/share/elasticsearch/data
        command: elasticsearch -Des.index.max_result_window=50000


    memcached:
        restart: always
        image: memcached:1
        command: memcached -m 2048m


    wirecloud:
        restart: always
        image: fiware/wirecloud
        depends_on:
            - postgres
            - elasticsearch
            - memcached
        environment:
            - DEBUG=False
            # - DEFAULT_THEME=wirecloud.defaulttheme
            - DB_HOST=postgres
            - DB_PASSWORD=wirepass   # Change this password!
            - FORWARDED_ALLOW_IPS=*
            - ELASTICSEARCH2_URL=http://elasticsearch:9200/
            - MEMCACHED_LOCATION=memcached:11211
            # Uncomment the following environment variables to enable IDM integration
            #- FIWARE_IDM_SERVER=${FIWARE_IDM_SERVER}
            #- SOCIAL_AUTH_FIWARE_KEY=${SOCIAL_AUTH_FIWARE_KEY}
            #- SOCIAL_AUTH_FIWARE_SECRET=${SOCIAL_AUTH_FIWARE_SECRET}
        volumes:
            - ./wirecloud-data:/opt/wirecloud_instance/data
            - ./wirecloud-static:/var/www/static
```

This `docker-compose.yml` file relies on a `nginx.conf` configuration file:

```nginx
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    server {

        listen 80;
        server_name example.org;
        client_max_body_size 20M;
        charset utf-8;

        location /static {
            alias /var/www/static;
        }

        location / {
            proxy_pass http://wirecloud:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

    }
}
```

Run `docker stack deploy -c docker-compose.yml wirecloud` (or `docker-compose -f docker-compose.yml up`), wait for it to initialize completely, and visit `http://swarm-ip`, `http://localhost`, or `http://host-ip` (as appropriate). Also, take into account that you should configure https to have a production-ready deployment of WireCloud (not covered by this example).



## Customizations

If you want to customize your WireCloud installation, the best option is to create a new docker image by extending one of the official images and installing new modules. For example, you can follow the following [tutorial](https://wirecloud.readthedocs.io/en/stable/development/platform/themes/) for creating a custom theme and install it on the extended image and use the `DEFAULT_THEME` environment variable to configure it as the default theme.


# License

View license information for [WireCloud](https://github.com/Wirecloud/wirecloud/blob/develop/LICENSE.txt).


# Supported Docker versions

This image is officially supported on Docker version 1.7.0.

Support for older versions (down to 1.0) is provided on a best-effort basis.


# User Feedback

## Documentation

This document should provide everything you need to install WireCloud using docker. Anyway, you can find the User & Programmer's Manual and the Administration Guides on [Read the Docs](https://wirecloud.readthedocs.io).


## Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/Wirecloud/docker-wirecloud/issues).

You can also reach many of the official image maintainers via the `fiware` and `fiware-wirecloud` tags on [StackOverflow](http://stackoverflow.com/questions/tagged/fiware-wirecloud).


## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/Wirecloud/docker-wirecloud/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
