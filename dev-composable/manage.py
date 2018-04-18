#!/usr/bin/env bash
CMD="python manage.py $@"
cd /opt/wirecloud_instance
${CMD}
