#!/bin/bash

set -e

MODULE=${MODULE:-website}

sed -i "s#module=website.wsgi:application#module=${MODULE}.wsgi:application#g" /opt/django/uwsgi.ini

if [ ! -f "/opt/django/app/manage.py" ]
then
  echo "creating basic django project (module: ${MODULE})"
  django-admin.py startproject ${MODULE} /opt/django/app/
else
  cd /opt/django/app/
  python3 manage.py compilemessages
  python3 manage.py collectstatic -c --noinput
  mkdir -p /opt/django/volatile && ln -s /opt/django/app/static /opt/django/volatile/static
fi

exec supervisord -c /opt/django/supervisord.conf
