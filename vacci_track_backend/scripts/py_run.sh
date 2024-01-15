#!/bin/sh

set -e

# Collect static files (if applicable)
python3 manage.py collectstatic --noinput

while true; do
  # Check PostgreSQL availability
  /py/bin/python /vacci_track_backend/scripts/check_postgres.py

  if [ $? -eq 0 ]; then
    break
  fi

  sleep 1
done

# Start uWSGI
uwsgi --ini /vacci_track_backend/uwsgi/uwsgi.ini


# python manage.py runserver 0.0.0.0:9000
