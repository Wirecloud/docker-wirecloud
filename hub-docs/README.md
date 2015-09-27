# Supported tags and respective `Dockerfile` links #

- [`0.7`, `latest`](https://github.com/Wirecloud/docker-wirecloud/blob/master/0.7/Dockerfile)
- [`0.6`](https://github.com/Wirecloud/docker-wirecloud/blob/master/0.6/Dockerfile)
- [`0.7-composable`, `latest-composable`](https://github.com/Wirecloud/docker-wirecloud/blob/master/0.7-composable/Dockerfile)
- [`0.6-composable`](https://github.com/Wirecloud/docker-wirecloud/blob/master/0.6-composable/Dockerfile)


## What is WireCloud?

Wirecloud builds on cutting-edge end-user development, RIA and semantic technologies to offer a next-generation end-user centred web application mashup platform aimed at leveraging the long tail of the Internet of Services. Wirecloud builds on cutting-edge end-user (software) development, RIA and semantic technologies to offer a next-generation end-user centred web application mashup platform aimed at allowing end users without programming skills to easily create web applications and dashboards/cockpits (e.g. to visualize their data of interest or to control their domotized home or environment). Web application mashups integrate heterogeneous data, application logic, and UI components (widgets) sourced from the Web to create new coherent and value-adding composite applications. They are targeted at leveraging the "long tail" of the Web of Services (a.k.a. the Programmable Web) by exploiting rapid development, DIY, and shareability. They typically serve a specific situational (i.e. immediate, short-lived, customized) need, frequently with high potential for reuse. Is this "situational" character which precludes them to be offered as 'off-the-shelf' functionality by solution providers, and therefore creates the need for a tool like Wirecloud

WireCloud is part of [FIWARE](https://www.fiware.org/). Check it out in the [Catalogue](https://catalogue.fiware.org/enablers/application-mashup-wirecloud)

## How to use this images.

There are two types of images, the "standalone" (`0.6`, `0.7` and `latest`) images and the "composable" (`0.6-composable`, `0.7-composable` and `latest-composable`) images.

The standalone images comes with everything ready to run `wirecloud` just with the image.

The composable images are designed to work with `docker-compose`.

To know how to get and run the standalone images go to the [Standalone Section](#Standalone).

To know how to get and run the composable images go to the [Composable Section](#Composable).

## Standalone

Running the standalone images are really simple. In the examples we are going to use the `latest` version but should work with `0.6` and `0.7` too.

First, we need to get and run the image:

```
docker run -d -p 80:80 --name wirecloud wirecloud/fiware-wirecloud:latest
```

Let's explain the command:
- `docker`: The main docker binary.
- `run`: To run the image.
- `-d`: Detach the image.
- `-p 80:80`: Assing the local port 80 to the image port 80. If you want to assign other port, for example, the port 8080, this would be: `-p 8080:80`
- `--name wirecloud`: Give a static name to the image running, this will be useful later when we want to stop and start again the instance without loosing data. The name can be whatever you want.
- `wirecloud/fiware-wirecloud:latest`: The name of the image.

Now you can go to the browser and see `wirecloud` in the browser. If you used the port 80, just go to [http://localhost](http://localhost).

If you want to stop/restart/start the instance, just execute:

```
# Stop the instance
docker stop wirecloud
# Start the instance
docker start wirecloud
# Restart the insance
docker restart wirecloud
```

In that way, you won't loose any data.

## Composable

This image is meant to be used with `docker-compose`.

[Docker compose](https://docs.docker.com/compose/) is a tool that allows you to defining and running multi-container applications with Docker.

First, install docker compose following [this steps](https://docs.docker.com/compose/install/)

> Take into account that some users have reporeted errors when instaing docker-compose from pip.

You can use [this example `docker-compose.yml` file](https://github.com/Wirecloud/docker-wirecloud/blob/master/hub-docs/compose-files/docker-compose.yml) as base for deploying your WireCloud infrastructure:

```yaml
nginx:
    restart: always
    image: wirecloud/django-nginx-composable:latest
    ports:
        - "80:80"
    volumes:
        - /www/static
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
    image: wirecloud/fiware-wirecloud:latest-composable
    links:
        - postgres:postgres
    volumes:
        - /var/www/static
    command: /usr/local/bin/gunicorn wirecloud_instance.wsgi:application -w 2 -b :8000
```

Once created the `docker-compose.yml` file, run the following command from the
same folder for starting all the containers:

```
$ docker-compose up -d
```

The `-d` flag start the services daemonized.

Now you have to initialize the database (PostgreSQL), to do that run this command and answer the questions to create the new super user (this step may fail if you installed `docker-compose` using pip):

```
$ docker-compose run wirecloud python manage.py syncdb --migrate
[...]
You just installed Django's auth system, which means you don't have any superusers defined.
Would you like to create one now? (yes/no): yes
Username (leave blank to use 'root'): admin
Email address: <yourmail>
Password: <yourpassword>
Password (again): <yourpassword>
Superuser created successfully.
[...]
```

Now your WireCloud instance is ready to be used! Open your browser and point it into port 80 of your docker machine.

### Other useful commands

- See the containers and the state

        $ docker-compose ps
                      Name                            Command               State           Ports
        --------------------------------------------------------------------------------------------------
        dockerwirecloud1_data_1            /docker-entrypoint.sh true       Up      5432/tcp
        dockerwirecloud1_nginx_1           /usr/sbin/nginx                  Up      0.0.0.0:80->80/tcp
        dockerwirecloud1_postgres_1        /docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp
        dockerwirecloud1_wirecloud_1       /usr/local/bin/gunicorn wi ...   Up      8000/tcp
        dockerwirecloud1_wirecloud_run_1   python manage.py syncdb -- ...   Up      8000/tcp

- See the logs:

        $ docker-compose logs


- Connect to the docker PostgreSQL (replace the IP with yours):

        $ psql -h 192.168.99.100 -p 5432 -U postgres --password


## License

View license information for [WireCloud](https://github.com/Wirecloud/wirecloud/blob/develop/LICENSE.txt).

## Supported Docker versions

This image is officially supported on Docker version 1.7.0.

Support for older versions (down to 1.0) is provided on a best-effort basis.
