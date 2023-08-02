#!/bin/sh

set -e

# python manage.py collectstatic --noinput

while true; do
  # Check if PostgreSQL server is available
  /py/bin/python /vacci_track_backend/scripts/check_postgres.py

  if [ $? -eq 0 ]; then
    break  # Break the loop if connection successful
  fi

  sleep 1
done


# uwsgi --ini /vacci_track_backend/uwsgi/uwsgi.ini

python manage.py runserver 0.0.0.0:8000
