# Wordpress with nodejs, composer and PHP QA tools including Wordpress-Coding-Standards
FROM wordpress

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.0.0

# install nodejs, php composer and php qa tools
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc \
  && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer \
  && apt-get update && apt-get install -y zlib1g-dev zip git \
  && composer global require "sebastian/phpcpd=*" \
  && composer global require "squizlabs/php_codesniffer=*" \
  && git clone git://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git /usr/share/php/PHP/CodeSniffer/Standards/WordPress \
  && composer global require "phpmd/phpmd=*" \
  && composer global require "mayflower/php-codebrowser=*" \
  && /root/.composer/vendor/bin/phpcs --config-set installed_paths /usr/share/php/PHP/CodeSniffer/Standards/WordPress

RUN npm install gulp -g
