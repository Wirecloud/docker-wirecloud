# Supported tags and respective `Dockerfile` links #

- [`1.1`, `latest`](https://github.com/Wirecloud/docker-wirecloud/blob/master/1.1/Dockerfile)
- [`1.1-composable`, `latest-composable`](https://github.com/Wirecloud/docker-wirecloud/blob/master/1.1-composable/Dockerfile)
- [`1.0`](https://github.com/Wirecloud/docker-wirecloud/blob/master/1.0/Dockerfile)
- [`1.0-composable`](https://github.com/Wirecloud/docker-wirecloud/blob/master/1.0-composable/Dockerfile)
- [`0.9`](https://github.com/Wirecloud/docker-wirecloud/blob/master/0.9/Dockerfile)
- [`0.9-composable`](https://github.com/Wirecloud/docker-wirecloud/blob/master/0.9-composable/Dockerfile)
- [`dev`](https://github.com/Wirecloud/docker-wirecloud/blob/master/dev/Dockerfile)
- [`dev-composable`](https://github.com/Wirecloud/docker-wirecloud/blob/master/dev-composable/Dockerfile)


## What is WireCloud?

WireCloud builds on cutting-edge end-user development, RIA and semantic technologies to offer a next-generation end-user centred web application mashup platform aimed at leveraging the long tail of the Internet of Services. WireCloud builds on cutting-edge end-user (software) development, RIA and semantic technologies to offer a next-generation end-user centred web application mashup platform aimed at allowing end users without programming skills to easily create web applications and dashboards/cockpits (e.g. to visualize their data of interest or to control their domotized home or environment). Web application mashups integrate heterogeneous data, application logic, and UI components (widgets) sourced from the Web to create new coherent and value-adding composite applications. They are targeted at leveraging the "long tail" of the Web of Services (a.k.a. the Programmable Web) by exploiting rapid development, DIY, and shareability. They typically serve a specific situational (i.e. immediate, short-lived, customized) need, frequently with high potential for reuse. Is this "situational" character which precludes them to be offered as 'off-the-shelf' functionality by solution providers, and therefore creates the need for a tool like WireCloud

WireCloud is part of [FIWARE](https://www.fiware.org/). Check it out in the [Catalogue](https://catalogue.fiware.org/enablers/application-mashup-wirecloud)

[![WireCloud's logo](https://raw.githubusercontent.com/Wirecloud/docker-wirecloud/master/logo.png)](https://github.com/Wirecloud/wirecloud)

## How to use these images.

There are two types of images, the "standalone" images and the "composable" images. The standalone images comes with everything ready to run WireCloud directly by running the image and without having to configure it (no recommended for production). The composable images are designed to work with `docker-compose` and support a more flexible configuration scheme.

## Standalone

Running the standalone images are really simple:

```
$ docker run --name some-wirecloud -d -p 80:80 fiware/wirecloud:latest
```

This example uses the `latest` version, but it should work also with versions `1.1`, `1.0` and `0.9`. Those images includes `EXPOSE 80` (the http port) so them can be used directly to serve WireCloud. Remember that those images are not meant to be used on production that will require configuring HTTPS.

### Customizations

The standalone image uses a volume for `/opt/wirecloud_instance` (the path where the WireCloud instance is stored), this means that any change you make to the `settings.py` file will be persisted.

If you want to use a different theme, you can create it on `/opt/wirecloud_instance`. See the [documentation](https://wirecloud.readthedocs.io/en/stable/development/platform/themes/) for more info.

> **Note**: Rembember that any change made outside the defined volume will be lost if the image is updated.

## Composable

This image is meant to be used with `docker-compose`.

[Docker compose](https://docs.docker.com/compose/) is a tool that allows you to defining and running multi-container applications with Docker.

First, install docker compose following [this steps](https://docs.docker.com/compose/install/)

> Take into account that some users have reporeted errors when instaing docker-compose from pip.

You can use [this example `docker-compose.yml` file](https://github.com/Wirecloud/docker-wirecloud/blob/master/hub-docs/docker-compose.yml):

```yaml
version: "3"

services:

    nginx:
        restart: always
        image: nginx:latest
        ports:
            - 80:80
        volumes:
            - ./nginx.conf:/etc/nginx/nginx.conf:ro
            - ./static:/var/www/static:ro
        links:
            - wirecloud:wirecloud


    postgres:
        restart: always
        image: postgres:latest
        volumes:
            - ./postgres-data:/var/lib/postgresql/data
        ports:
            - 127.0.0.1:5432:5432


    wirecloud:
        restart: always
        image: fiware/wirecloud:latest-composable
        links:
            - postgres:postgres
        depends_on:
            - postgres
        ports:
            - 127.0.0.1:8000:8000
        volumes:
            - ./wirecloud_instance:/opt/wirecloud_instance
            - ./static:/var/www/static
```

and [this `nginx.conf` file](https://github.com/Wirecloud/docker-wirecloud/blob/master/hub-docs/nginx.conf) as base for deploying your WireCloud infrastructure:

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

Once created the `docker-compose.yml` and the `nginx.conf` files, run the following command from the same folder for starting all the containers:

```
$ docker-compose up -d
```

This docker-compose configuration will detect when the WireCloud configuration is missing and, in that case, it will populate the volume at `/opt/wirecloud_instance` (mapped to the local `wirecloud_instance` folder), the database and the `/var/www/static` volume (mapped to the local `static` folder). This initial configuration will not include any administrator user so, please create one using the `createsuperuser` command.


### Running manage.py commands

You can run any available `manage.py` command by using `docker-compose exec manage.py`. For example, you can create superusers/administrators by running the following command:

```
$ docker-compose exec wirecloud manage.py createsuperuser
Username (leave blank to use 'root'): admin
Email address: ${youremail}
Password: ${yourpassword}
Password (again): ${yourpassword}
Superuser created successfully.
```

Regarding commands using the filesystem, take into account that those commands will be executed inside the container and thus the filesystem will be the one used by the container. The `manage.py` script will not check if those commands make changes outside the provided volumes. Anyway, they can be used without any problem. For example, static files can be collected using the following command:

```
$ docker-compose exec manage.py collectstatic
```

Use `docker-compose exec wirecloud manage.py --help` for getting the list of available commands.


### Customizations

The composable image uses two volumes, one for `/opt/wirecloud_instance` and another for `/var/www/static`. The only difference with the standalone image is that the static files are stored in `/var/www/static` instead of being stored in `/opt/wirecloud_instance/static`.

> **Note**: Rembember that any change made outside the defined volumes will be lost if the image is updated.

Composable images comes preloaded with some python modules to allow enabling extra functionalities. Those modules are:

- `python-social-auth`: Required to enable IdM configuration.
- `pylibmc`: Required to use memcached.


## License

View license information for [WireCloud](https://github.com/Wirecloud/wirecloud/blob/develop/LICENSE.txt).

## Supported Docker versions

This image is officially supported on Docker version 1.7.0.

Support for older versions (down to 1.0) is provided on a best-effort basis.

## User Feedback

### Documentation

This document should provide everything you need to install WireCloud using docker. Anyway, you can find the User & Programmer's Manual and the Administration Guides on [Read the Docs](https://wirecloud.readthedocs.io).

### Issues

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/Wirecloud/docker-wirecloud/issues).

You can also reach many of the official image maintainers via the `fiware` and `fiware-wirecloud` tags on [StackOverflow](http://stackoverflow.com/questions/tagged/fiware-wirecloud).

### Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/Wirecloud/docker-wirecloud/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
