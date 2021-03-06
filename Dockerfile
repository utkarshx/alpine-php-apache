FROM alpine:3

# Setup apache and php
RUN apk --update add apache2 php7-apache2 curl \
    php7-json php7-phar php7-openssl php7-mysqli php7-curl php7-tokenizer php7-zip php7-mbstring php7-fileinfo php7-simplexml php7-xmlwriter php7-pdo_sqlite php7-session php7-xmlreader php7-mcrypt php7-pdo_mysql php7-ctype php7-gd php7-xml php7-dom php7-iconv \
    && rm -f /var/cache/apk/* \
    && mkdir -p /opt/utils
    
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN sed -i 's/Listen 80/Listen 5000/g' /etc/apache2/httpd.conf
EXPOSE 5000

WORKDIR /app

RUN chown -R apache:apache /app \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log \
    && sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule\ deflate_module/LoadModule\ deflate_module/' /etc/apache2/httpd.conf \
    && sed -i 's/#LoadModule\ expires_module/LoadModule\ expires_module/' /etc/apache2/httpd.conf \
    && sed -i "s#^DocumentRoot \".*#DocumentRoot \"/app/\"#g" /etc/apache2/httpd.conf \
    && sed -i "s#/var/www/localhost/htdocs#/app/#" /etc/apache2/httpd.conf \
    && printf "\n<Directory \"/app/\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf

CMD httpd -D FOREGROUND
