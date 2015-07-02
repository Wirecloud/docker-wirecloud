WireCloud is part of [FIWARE](http://www.fiware.org/).

See the Dockerfiles [here](https://github.com/Wirecloud/docker-wirecloud).

## Requisites

You need to have a running instance of PostgreSQL, you can do it manually or follow the steps bellow to setup all with `docker-compose`.

## Supported tags and respective `Dockerfile` links

- [`0.7`, `latest`](https://github.com/Wirecloud/docker-wirecloud/blob/master/0.7/Dockerfile)
- [`0.6`](https://github.com/Wirecloud/docker-wirecloud/blob/master/0.6/Dockerfile)

## Running with Docker Compose and Docker machine

[Docker compose](https://docs.docker.com/compose/) is a tool that allows you to defining and running multi-container applications with Docker.
[Docker machine](https://docs.docker.com/machine/) is another tool that provides the ability to create Docker hosts in a computer, cloup provider or data center.

First, install docker compose following [this steps](https://docs.docker.com/compose/install/). Do not install from pip, there are some problems in the pip version with the terminal forwarding.
Then, install docker compose following [this steps](https://docs.docker.com/machine/).

Check that you have installed with:

```
$ docker-machine --version
docker-machine version 0.3.0 (0a251fe)
$ docker-compose --version
docker-compose version: 1.3.1
```

Once you have all installed, you need a docker-compose.yml to define the containers, the base file that you can use is [this](https://github.com/Wirecloud/docker-wirecloud/blob/master/hub-docks/compose-files/docker-compose.yml):
```
nginx:
    restart: always
    build: ./nginx/
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
    command: true

wirecloud:
    restart: always
    image: wirecloud/fiware-wirecloud:latest
    expose:
        - "8000"
    links:
        - postgres:postgres
    volumes:
        - /var/www/static
    command: /usr/local/bin/gunicorn wirecloud_instance.wsgi:application -w 2 -b :8000
```

This docker-compose file uses a custom nginx container that allow us to redirect the ports without configure anything, you can download it from [here](https://github.com/Wirecloud/docker-wirecloud/blob/master/hub-docks/compose-files/nginx) and place the directory `nginx` in the same level than `docker-compose.yml`.

Before starting you need to create a docker machine, you can do it with this command:
```
$ docker-machine create -d virtualbox dev;
```

This will create a "Machine" called `dev` using virtualbox. Now point Docker to this Machine:

```
$ eval "$(docker-machine env dev)"
```

You can see that the Machine is running:

```
$ docker-machine ls
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM
dev             virtualbox   Running   tcp://192.168.99.100:2376
```

Now, you need to build the docker containers (will build nginx container), type in your terminal:

```
$ docker-compose build
```

And now, start the service!

```
$ docker-compose up -d
```

The `-d` flag start the services daemonized.

Now you have to initialize the database (PostgreSQL), to do that run this command and answer the questions to create the new super user (this step will fail if you installed `docker-compose` from pip):

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

You have installed and running WireCloud!

Now you can access it with the docker-machine ip:

```
$ docker-machine ip dev
192.168.99.100
```

Go to your browser and open that IP, you will see the WireCloud instance.


Some useful command for docker compose are the following:

- See the containers and the state
```
$ docker-compose ps
              Name                            Command               State           Ports
--------------------------------------------------------------------------------------------------
dockerwirecloud1_data_1            /docker-entrypoint.sh true       Up      5432/tcp
dockerwirecloud1_nginx_1           /usr/sbin/nginx                  Up      0.0.0.0:80->80/tcp
dockerwirecloud1_postgres_1        /docker-entrypoint.sh postgres   Up      0.0.0.0:5432->5432/tcp
dockerwirecloud1_wirecloud_1       /usr/local/bin/gunicorn wi ...   Up      8000/tcp
dockerwirecloud1_wirecloud_run_1   python manage.py syncdb -- ...   Up      8000/tcp
```

- See the logs
```
$ docker-compose logs
```

- Connect to the docker PostgreSQL (replace the IP with yours)
```
$ psql -h 192.168.99.100 -p 5432 -U postgres --password
```
