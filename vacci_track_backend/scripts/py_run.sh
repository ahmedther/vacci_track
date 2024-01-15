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

# Add cron job to remove files at 4:45 AM every night and log the output
(crontab -l 2>/dev/null; echo "45 4 * * * rm -rf /vacci_track_backend/excel_media/* > /var/log/cron.log 2>&1") | crontab -

# Start Cron service
cron
# Start uWSGI
uwsgi --ini /vacci_track_backend/uwsgi/uwsgi.ini


# python manage.py runserver 0.0.0.0:9000
