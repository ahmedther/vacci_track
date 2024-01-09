FROM python:3.12.1-slim as builder


ENV PYTHONUNBUFFERED 1

WORKDIR /vacci_track_backend

COPY ./requirements.txt ./


RUN apt update -y \
    && apt install  libpq-dev gcc libaio1  -y \ 
    && python3 -m venv /py \
    && /py/bin/pip install --upgrade pip \
    && /py/bin/pip install --no-cache --no-cache-dir -r ./requirements.txt  \
    && apt-get purge -y curl  unzip libpq-dev gcc libaio1 \ 
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && apt autoremove -y  


FROM python:3.12.1-slim

ENV PYTHONUNBUFFERED 1

COPY --from=builder /py /py

WORKDIR /vacci_track_backend

COPY ./ ./


RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 cron curl unzip libaio1 \
    && cd /tmp \
    && curl -o instantclient-basiclite-linux.x64-21.9.0.0.0dbru.zip https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-basiclite-linux.x64-21.9.0.0.0dbru.zip \
    && unzip -d . instantclient-basiclite-linux.x64-21.9.0.0.0dbru.zip \
    && rm -f instantclient-basiclite-linux.x64-21.9.0.0.0dbru.zip \
    && mkdir -p /opt/oracle/instantclient \
    && mv instantclient*/* /opt/oracle/instantclient \ 
    && echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf  \
    && ldconfig \
    && ln -snf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && echo Asia/Kolkata > /etc/timezone \
    && mkdir /var/log/uwsgi \
    && touch /var/log/uwsgi/vacci_track_backend.log \
    && apt-get purge -y curl  unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && apt autoremove -y  \
    && export DPI_DEBUG_LEVEL=64 

LABEL maintainer='ahmed'


ENV LD_LIBRARY_PATH=/opt/oracle/instantclient

ENV PATH="/vacci_track_backend/scripts:/py/bin:$PATH"

CMD ["py_run.sh"]




# FROM python:3.12.1-alpine3.19 as builder


# ENV PYTHONUNBUFFERED 1

# WORKDIR /vacci_track_backend

# COPY ./requirements.txt ./


# RUN apk update && apk add --no-cache musl-dev gcc postgresql-dev linux-headers \
#     && python3 -m venv /py \ 
#     && /py/bin/pip install --upgrade pip \
#     && /py/bin/pip install --no-cache-dir -r ./requirements.txt \
#     && apk del musl-dev gcc postgresql-dev linux-headers \ 
#     && rm -rf /var/cache/apk/* /root/.cache 



# FROM python:3.12.1-alpine3.19

# ENV PYTHONUNBUFFERED 1

# COPY --from=builder /py /py 

# WORKDIR /vacci_track_backend


# COPY ./ ./


# RUN apk update && apk add --no-cache libaio libnsl libc6-compat postgresql-libs cronie curl unzip \
#     && curl -o instantclient-basiclite-linuxx64.zip https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip -SL \
#     && unzip -d . instantclient-basiclite-linuxx64.zip \
#     && rm -f instantclient-basiclite-linuxx64.zip   \
#     && mkdir -p /opt/oracle/instantclient \
#     && mv instantclient*/* /opt/oracle/instantclient\ 
#     && chmod -R 777 /opt/oracle/instantclient \
#     && mkdir -p /etc/ld.so.conf.d \
#     && echo /opt/oracle/instantclient/ > /etc/ld.so.conf.d/oracle-instantclient.conf \
#     && ldconfig /etc/ld.so.conf.d/ \
#     && ln -snf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime && echo Asia/Kolkata > /etc/timezone \
#     && mkdir /var/log/uwsgi \
#     && touch /var/log/uwsgi/vacci_track_backend.log \
#     && apk del curl unzip \
#     && export DPI_DEBUG_LEVEL=64

# LABEL maintainer='ahmed'


# ENV LD_LIBRARY_PATH=/opt/oracle/instantclient

# ENV PATH="/vacci_track_backend/scripts:/py/bin:/opt/oracle/instantclient:$PATH"

# CMD ["py_run.sh"]


