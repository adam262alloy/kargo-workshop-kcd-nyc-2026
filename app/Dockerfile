# Lightweight static guestbook frontend served by Nginx.
# LAMBDA_URL / STAGE env vars are baked into config.js at container start by an
# entrypoint script (Nginx runs everything in /docker-entrypoint.d before serving).
FROM nginx:stable-alpine

COPY index.html script.js style.css /usr/share/nginx/html/
COPY default.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.d/10-render-config.sh /docker-entrypoint.d/10-render-config.sh
RUN chmod +x /docker-entrypoint.d/10-render-config.sh

EXPOSE 80
