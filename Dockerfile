FROM mediawiki:1.31

RUN apt-get update -qq && apt-get install -y software-properties-common apt-transport-https gnupg
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update -qq && apt-add-repository "deb https://releases.wikimedia.org/debian jessie-mediawiki main"
RUN apt-get update -qq && apt-get install -y nodejs parsoid --allow-unauthenticated

COPY parsoid /etc/mediawiki/parsoid
RUN apt-get update -qq && apt-get install -y wget zip

COPY --from=composer:1.7 /usr/bin/composer /usr/bin/composer
RUN composer require mediawiki/semantic-media-wiki --update-no-dev
RUN pear install net_smtp

COPY conf /conf

COPY dokku-entrypoint.sh entrypoint.sh \ 
     composer-install.sh composer.local.json \ 
     install-update-php-dependencies.sh /
COPY extensions /var/www/html/extensions
COPY VectorTemplate.php /var/www/html/skins/Vector/includes/VectorTemplate.php
COPY nginx.conf.sigil .htaccess /var/www/html/

RUN ln -s /storage/images /var/www/html/images

EXPOSE 80 443
ENTRYPOINT ["/dokku-entrypoint.sh"]
CMD ["apachectl", "-e", "info", "-D", "FOREGROUND"]
