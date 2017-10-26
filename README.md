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

[![WireCloud's logo](logo.png)](https://github.com/Wirecloud/wirecloud)

## How to use these images.

There are two types of images, the "standalone" images and the "composable" images. The standalone images comes with everything ready to run WireCloud directly by running the image and without having to configure it (no recommended for production). The composable images are designed to work with `docker-compose` and support a more flexible configuration scheme.

## Standalone

Running the standalone images are really simple. In the examples we are going to use the `latest` version but should work with `0.8` and `0.9` too.

First, we need to get and run the image:

```
docker run -d -p 80:80 --name wirecloud fiware/wirecloud:latest
```

Let's explain the command:
- `docker`: The main docker binary.
- `run`: To run the image.
- `-d`: Detach the image.
- `-p 80:80`: Assing the local port 80 to the image port 80. If you want to assign other port, for example, the port 8080, this would be: `-p 8080:80`
- `--name wirecloud`: Give a static name to the image running, this will be useful later when we want to stop and start again the instance without loosing data. The name can be whatever you want.
- `fiware/wirecloud:latest`: The name of the image.

Now you can go to the browser and see `wirecloud` in the browser. If you used the port 80, just go to [http://localhost](http://localhost).

If you want to stop/restart/start/admin the instance, just execute:

```
# Stop the instance
docker stop wirecloud
# Start the instance
docker start wirecloud
# Restart the instance
docker restart wirecloud
# Open a terminal on the instance
docker -it wirecloud /bin/bash
```

### Customizations

The standalone image uses a volume for `/opt/wirecloud_instance` (the path where the WireCloud instance is stored), this means that any change you make to the `settings.py` file will be persisted.

If you want to use a different theme, you can create it on `/opt/wirecloud_instance`. See the [documentation](https://wirecloud.readthedocs.io/en/stable/development/platform/themes/) for more info.

> **Note**: Rembember that any change made outside the defined volumes will be lost if the image is updated.

## Composable

This image is meant to be used with `docker-compose`.

[Docker compose](https://docs.docker.com/compose/) is a tool that allows you to defining and running multi-container applications with Docker.

First, install docker compose following [this steps](https://docs.docker.com/compose/install/)

> Take into account that some users have reporeted errors when instaing docker-compose from pip.

You can use [this example `docker-compose.yml` file](https://github.com/Wirecloud/docker-wirecloud/blob/master/hub-docs/docker-compose.yml):

```yaml
nginx:
    restart: always
    image: nginx:latest
    ports:
        - "80:80"
    volumes:
        - ./nginx.conf:/etc/nginx/nginx.conf:ro
    volumes_from:
        - wirecloud
    links:
        - wirecloud:wirecloud

postgres:
    restart: always
    image: postgres:latest
    volumes_from:
        - data
    ports:
        - "5432:5432"

data:
    restart: always
    image: postgres:latest
    volumes:
        - /var/lib/postgresql
    command: /bin/true

wirecloud:
    restart: always
    image: fiware/wirecloud:latest-composable
    links:
        - postgres:postgres
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

Once created the `docker-compose.yml` and the `nginx.conf` files, run the
following command from the same folder for starting all the containers:

```
$ docker-compose up -d
```

The `-d` flag start the services daemonized.

Now you have to initialize the database (PostgreSQL) by running the `initdb` command but, before running it, we have to obtain the container name assigned to the wirecloud service. This can be accomplished by running the `docker-compose ps` command:

```
$ docker-compose ps
         Name                        Command               State           Ports
-----------------------------------------------------------------------------------------
hubdocs_data_1            /docker-entrypoint.sh /bin ...   Up      5432/tcp
hubdocs_nginx_1           /usr/sbin/nginx                  Up      0.0.0.0:80->80/tcp
hubdocs_postgres_1        /docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp
hubdocs_wirecloud_1       /docker-entrypoint.sh            Up      8000/tcp
```

In this case, the container is called `hubdocs_wirecloud_1`, so we have to run the following command:

```
$ docker exec -it hubdocs_wirecloud_1 /docker-entrypoint.sh initdb
```

Once initalized the db, you have to create an administrator user:

```
$ docker exec -it hubdocs_wirecloud_1 /docker-entrypoint.sh createsuperuser
Username (leave blank to use 'root'): admin
Email address: ${youremail}
Password: ${yourpassword}
Password (again): ${yourpassword}
Superuser created successfully.
```

> **Note**: You don't need to execute the `createsuperuser` command when using version 0.8 of the image as those images make uses of the `syncdb` command available on Django 1.7:
>
> ```
> $ docker exec -it hubdocs_wirecloud_1 /docker-entrypoint.sh initdb
> [...]
> You just installed Django's auth system, which means you don't have any superusers defined.
> Would you like to create one now? (yes/no): yes
> Username (leave blank to use 'root'): admin
> Email address: ${youremail}
> Password: ${yourpassword}
> Password (again): ${yourpassword}
> Superuser created successfully.
> [...]
> ```

Now your WireCloud instance is ready to be used! Open your browser and point it to your docker machine using `http://` (e.g. `http://192.168.99.100`).

### Customizations

The composable image uses two volumes, one for `/opt/wirecloud_instance` and another for `/var/www/static`. The only difference with the standalone image is that the static files are stored in `/var/www/static` instead of being stored in `/opt/wirecloud_instance/static`.

> **Note**: Rembember that any change made outside the defined volumes will be lost if the image is updated.

### Other useful commands

- See the logs:

        $ docker-compose logs


- Connect to the docker PostgreSQL (replace the IP with yours):

        $ psql -h 192.168.99.100 -p 5432 -U postgres --password


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
