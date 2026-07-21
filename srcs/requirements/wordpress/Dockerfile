FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y php7.4 php7.4-fpm php7.4-mysqli mariadb-client curl
RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/.
COPY tools/init_script.sh /.
RUN chmod +x /init_script.sh

ENTRYPOINT [ "/init_script.sh" ]