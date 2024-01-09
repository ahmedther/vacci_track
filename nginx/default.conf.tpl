upstream app_server {
    server app:${SERVE_DJANGO_ON};
}

server {
    # Django backend
    listen ${LISTEN_PORT_DJANGO};

    client_max_body_size 100m;
    client_body_buffer_size 100m;

    access_log /var/log/nginx/vacci_track_backend_access.log;
    error_log /var/log/nginx/vacci_track_backend_log_error.log;

    client_body_timeout 7200s;
    client_header_timeout 7200s;
    keepalive_timeout 7200s;
    send_timeout 7200s;

    location /static {
    root /vacci_track_backend/static;
    }

    location / {
        # to use without uwsgi_params
        # proxy_pass http://app_server; 
        # proxy_set_header Host localhost;
        proxy_read_timeout 7200s;
        proxy_connect_timeout 7200s;
        proxy_send_timeout 7200s;
        uwsgi_pass app_server;
        include /etc/nginx/uwsgi_params;

        # Set uWSGI timeout to one day (86400 seconds)
        uwsgi_read_timeout 7200;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
}

   
server {
    # Listen for incoming connections on port 80
    listen ${LISTEN_PORT_FLUTTER};

    # Server name configuration (optional)
    # If you have a specific domain name, replace _ with your domain
    server_name localhost;

    # Root directory where the Flutter app files are located
    root /usr/share/nginx/html;

    # Set the default index file to index.html
    index index.html;

    # Logging:
    access_log /var/log/nginx/flutter_access.log;
    error_log /var/log/nginx/flutter_error.log;

    location / {
        # Attempt to serve the requested file directly,
        # or redirect to index.html if not found
        root /usr/share/nginx/html;
        index index.html index.htm;
        #try_files $uri $uri/ /index.html;
    }

}

