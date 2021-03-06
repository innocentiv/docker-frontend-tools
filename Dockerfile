# encelado748/docker-frontend-tools
# VERSION 1.0.1

FROM ubuntu:latest

# Forked from webgefrickel/docker-frontend-tools
MAINTAINER Valerio Innocenti Sedili <vinnocenti@outlook.it>

# set the wanted versions for dev-tools here
# other tools will be installed too, but the versions for those
# is not really relevant - most are capsuled in gulp/grunt-*
# node-modules anyways - the others are just for convenience
ENV GULP_VERSION 3.9.1
ENV GRUNT_VERSION 1.2.0
ENV SASS_VERSION 3.4.22
ENV COMPASS_VERSION 1.0.3
ENV GOSU_VERSION 1.9

# install gosu
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apt-get purge -y --auto-remove ca-certificates wget

# global dependencies / build-essentials and cli-tools
RUN \
  apt-get update \
  && apt-get install -y --force-yes build-essential git curl \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install most current node and global node packages
RUN \
  apt-get update \
  && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
  && apt-get install -y --no-install-recommends nodejs  \
  && curl -sL https://npmjs.org/install.sh | sh \
  && npm install -g gulp@$GULP_VERSION \
  && npm install -g grunt-cli@$GRUNT_VERSION \
  && npm install -g bower \
  && npm install -g browserify \
  && npm install -g eslint \
  && npm install -g jsonlint \
  && npm install -g npm-check-updates \
  && npm install -g stylestats \
  && npm install -g foundation-cli \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install ruby (2.3 in ubuntu) and frontend gems (without docs)
# ruby-dev is needed for building native compass extensions
RUN \
  apt-get update \
  && apt-get install -y --force-yes --no-install-recommends ruby ruby-dev  \
  && gem install sass --no-document --version $SASS_VERSION \
  && gem install compass --no-document --version $COMPASS_VERSION \
  && gem install scss_lint --no-document \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# create the working dir
RUN mkdir /code

# set the working dir
WORKDIR /code

# copy entrypoint to setup new user after login
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN \
  chown root:root /usr/local/bin/entrypoint.sh \
  && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]