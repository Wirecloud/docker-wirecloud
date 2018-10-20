#!/usr/bin/env bash
cd /opt/wirecloud_instance
gosu wirecloud python manage.py $@
