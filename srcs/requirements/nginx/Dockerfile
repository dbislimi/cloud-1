FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y
RUN apt-get install nginx -y
RUN apt-get install openssl -y

RUN mkdir -p /etc/nginx/ssl
RUN chmod 700 /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/inception.key -out /etc/nginx/ssl/inception.crt -subj "/C=FR/ST=REGION SUD/L=Nice/O=42/OU=42/CN=dbislimi.42.fr/UID=dbislimi"

RUN rm -f /etc/nginx/sites-enabled/default
COPY conf/dbislimi.42.fr.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/dbislimi.42.fr.conf /etc/nginx/sites-enabled/

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]