FROM mediawiki:1.31

RUN apt-get update -qq && apt-get install -y software-properties-common apt-transport-https gnupg wget zip && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update -qq && apt-add-repository "deb https://releases.wikimedia.org/debian jessie-mediawiki main" && \
    apt-get update -qq && apt-get install -y ghostscript poppler-utils nodejs parsoid --allow-unauthenticated --no-install-recommends && \
    mv ./images ./images-old && ln -s /storage/images ./ && cd /var/www/html/extensions && \
    curl -L https://extdist.wmflabs.org/dist/extensions/CookieWarning-REL1_31-8ab2dfc.tar.gz | tar xz && \
    curl -L https://extdist.wmflabs.org/dist/extensions/MsUpload-REL1_31-d854ddf.tar.gz | tar xz && \
    curl -L https://extdist.wmflabs.org/dist/extensions/ArticleFeedbackv5-REL1_31-e42624e.tar.gz | tar xz && \
    rm -rf /var/lib/apt/lists/*

COPY parsoid /etc/mediawiki/parsoid
COPY conf /conf
COPY dokku-entrypoint.sh entrypoint.sh \ 
     composer-install.sh composer.local.json \ 
     install-update-php-dependencies.sh /
COPY extensions extensions/
COPY VectorTemplate.php skins/Vector/includes/VectorTemplate.php
COPY nginx.conf.sigil .htaccess ./
COPY extension.json extensions/ArticleFeedbackv5/extension.json
COPY jquery.appear.js extensions/ArticleFeedbackv5/modules/jquery.articleFeedbackv5

EXPOSE 80 443
ENTRYPOINT ["/dokku-entrypoint.sh"]

CMD ["apachectl", "-e", "info", "-D", "FOREGROUND"]
