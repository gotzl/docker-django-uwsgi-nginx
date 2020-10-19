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
  mkdir -p /opt/django/volatile && [ -L /opt/django/volatile/static ] || ln -s /opt/django/app/static /opt/django/volatile/static
fi


# when useing postgres, make sure the service is reachable
if [ -n "$DB_TYPE" -a "$DB_TYPE" = "postgres" ]; then
  [ -z ${DB_NAME+x} ] && DB_NAME="registration"
  [ -z ${DB_HOST+x} ] && DB_HOST="postgres"
  [ -z ${DB_USER+x} ] && DB_USER="postgres"
  [ -z ${DB_PASSWORD+x} ] && DB_PASSWORD="postgres"
  until PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -c '\q'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
  done
  set +e
  ret=$(PGPASSWORD=$DB_PASSWORD createdb -h "$DB_HOST" -U "$DB_USER" "$DB_NAME")
  if [ $? -eq 0 ]; then
    python3 manage.py makemigrations registration
    python3 manage.py migrate
  fi
  set -e
fi

exec supervisord -c /opt/django/supervisord.conf
