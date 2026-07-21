#!/bin/bash

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html
if [ ! -d "wp-content" ]; then
    wp core download --version=6.4.3 --allow-root
fi
if [ ! -f "wp-config.php" ]; then
	wp config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWD --dbhost=mariadb:3306 --allow-root
fi
if ! wp core is-installed --allow-root 2>/dev/null; then
    wp core install --url=dbislimi.42.fr --title=$TITLE --admin_user=$WP_ADMIN_NAME --admin_password=$WP_ADMIN_PASSWD --admin_email=boss@boss.com --allow-root
fi

if ! wp user exists 2 --allow-root 2>/dev/null; then
    wp user create $WP_USER_NAME dbislimi@dbislimi.com --user_pass=$WP_USER_PASSWD --allow-root
fi
php-fpm7.4 -F