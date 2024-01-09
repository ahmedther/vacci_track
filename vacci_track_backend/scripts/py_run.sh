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

# Add cron job to remove files at 2:00 AM every night
(crontab -l 2>/dev/null; echo "* * * * * rm -rf /vacci_track_backend/excel_media/*") | crontab -

#Start Cron service
cron

# Start uWSGI
uwsgi --ini /vacci_track_backend/uwsgi/uwsgi.ini


# python manage.py runserver 0.0.0.0:9000
