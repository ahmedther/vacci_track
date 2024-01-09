FROM nginx:alpine-slim

LABEL maintainer='ahmed'

COPY ./nginx/default.conf.tpl /etc/nginx/default.conf.tpl
COPY ./nginx/nginx_run.sh ./nginx_run.sh
COPY ./vacci_track_frontend/build/web /usr/share/nginx/html
COPY ./nginx/uwsgi_params /etc/nginx/uwsgi_params

CMD ["./nginx_run.sh"]