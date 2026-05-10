FROM alpine:3.23.2

ARG LINKSTACK_VERSION=v4.8.6

LABEL modified_by="Sc4ndium90"
LABEL maintainer="JulianPrieber"
LABEL description="LinkStack Docker"

EXPOSE 80 443

# Setup apache and php
RUN apk --no-cache --update \
    add apache2 \
    apache2-ssl \
    curl \
    php83-apache2 \
    php83-bcmath \
    php83-bz2 \
    php83-calendar \
    php83-common \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-fileinfo \
    php83-gd \
    php83-iconv \
    php83-json \
    php83-mbstring \
    php83-mysqli \
    php83-mysqlnd \
    php83-openssl \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pdo_sqlite \
    php83-phar \
    php83-session \
    php83-xml \
    php83-tokenizer \
    php83-zip \
    php83-xmlwriter \
    php83-redis \
    su-exec \
    tzdata 

RUN wget "https://github.com/LinkStackOrg/LinkStack/releases/download/${LINKSTACK_VERSION}/linkstack.zip" -O /tmp/linkstack.zip && \
        mkdir -p /usr/src/linkstack /tmp/linkstack /htdocs && unzip /tmp/linkstack.zip -d /tmp/linkstack && cp -Rp /tmp/linkstack/linkstack/. /usr/src/linkstack && \
        rm -rf /tmp/linkstack.zip /tmp/linkstack

COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin
COPY configs/apache2/httpd.conf /etc/apache2/httpd.conf
COPY configs/apache2/ssl.conf /etc/apache2/conf.d/ssl.conf
COPY configs/php/php.ini /etc/php83/conf.d/40-custom.ini

RUN chown apache:apache /etc/ssl/apache2/server.pem
RUN chown apache:apache /etc/ssl/apache2/server.key

RUN chmod -R 755 /etc/php83 && \
    chown -R apache:apache /etc/php83

HEALTHCHECK CMD curl -f http://localhost -A "HealthCheck" || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd", "-d", "FOREGROUND"]
