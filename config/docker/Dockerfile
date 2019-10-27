FROM debian:10.1-slim

MAINTAINER Leonardo Lobo Lima <dleemoo@gmail.com>

ENV LANG=C.UTF-8 \
    APP_USER_ID=1000 \
    APP_GROUP_ID=100 \
    APP_HOME=/app \
    APP_USER_HOME=/home/app \
    GOSU_DOWNLOAD_SHA256=0b843df6d86e270c5b0f5cbd3c326a04e18f4b7f9b8457fa497b0454c4b138d7 \
    ENTRYPOINT_SHA256=40cb6c9eec89788799722d2cc723ec9fbae22271a77763df2b90a4d8b7446100

RUN set -ex \
  # add debian packages for essential runtime libraries
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
     apt-transport-https autoconf bison build-essential curl git libffi-dev \
     libgdbm-dev libncurses-dev libreadline-dev libssl-dev libyaml-dev zlib1g-dev

RUN set -ex \
  #
  # Basic setup (packages) and entrypoint for use container as normal user
  #
  # files to run container as normal user
  && curl -sfL https://git.io/fjHqX -o /usr/share/entrypoint.sh \
  && curl -sfL https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64 -o /usr/local/bin/gosu \
  # check files integrity
  && echo "$GOSU_DOWNLOAD_SHA256 /usr/local/bin/gosu" | sha256sum -c - \
  && echo "$ENTRYPOINT_SHA256 /usr/share/entrypoint.sh" | sha256sum -c - \
  # setup basic environment to run as normal user and use /gems/bin
  && mkdir -p $APP_HOME $APP_USER_HOME \
  && chmod +x /usr/share/entrypoint.sh /usr/local/bin/gosu \
  && useradd --uid $APP_USER_ID --gid $APP_GROUP_ID app \
  && chown -R app. $APP_HOME $APP_USER_HOME \
  # clean up apt files
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV PG_VERSION=12.0 \
    PG_DOWNLOAD_SHA256=15c7f267b476d764c79401d7f61f39c76222314951f77e6893a5854db26b6616

RUN set -ex \
  #
  # setup postgres client libs and headers
  #
  && curl -sL http://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz -o /tmp/postgresql.tar.gz \
  && echo "$PG_DOWNLOAD_SHA256 /tmp/postgresql.tar.gz" | sha256sum -c - \
  && mkdir -p /tmp/postgresql \
  && tar -xzf /tmp/postgresql.tar.gz -C /tmp/postgresql --strip-components=1

RUN set -ex \
  && cd /tmp/postgresql \
  && echo "Building postgresql ..." \
  && CFLAGS="-O3 -pipe" ./configure --prefix=/usr/local 1>/dev/null

RUN set -ex \
  && cd /tmp/postgresql \
  && make -j"$(getconf _NPROCESSORS_ONLN)" \
  && make -j"$(getconf _NPROCESSORS_ONLN)" -C src/include install \
  && make -j"$(getconf _NPROCESSORS_ONLN)" -C src/bin install \
  && make -j"$(getconf _NPROCESSORS_ONLN)" -C src/interfaces install \
  && cd /tmp \
  && rm -rf /tmp/postgresql*

ENV RUBY_MAJOR=2.6 \
    RUBY_VERSION=2.6.5 \
    RUBY_DOWNLOAD_SHA256=66976b716ecc1fd34f9b7c3c2b07bbd37631815377a2e3e85a5b194cfdcbed7d

RUN set -ex \
  #
  # Ruby setup
  #
  && curl -sL "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" -o /tmp/ruby.tar.xz \
  # && echo "$RUBY_DOWNLOAD_SHA256 /tmp/ruby.tar.xz" | sha256sum -c - \
  && mkdir -p /tmp/ruby \
  && tar xf /tmp/ruby.tar.xz -C /tmp/ruby --strip-components=1 \
  && cd /tmp/ruby \
  && autoconf 1>/dev/null \
  && ac_cv_func_isnan=yes ac_cv_func_isinf=yes ./configure --disable-install-doc --enable-shared 1>/dev/null \
  && make -j"$(getconf _NPROCESSORS_ONLN)" 1>/dev/null \
  && make install 1>/dev/null \
  && make DESTDIR=/ruby install 1>/dev/null \
  # do not generate gem docs by default
  && mkdir -p /usr/local/etc && { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc \
  # install basic gems in global space
  && gem install bundle pry \
  && gem update \
  && gem update --system 1>/dev/null \
  # remove temporary files
  && rm -rf /tmp/ruby*

ENV GEM_HOME=/gems \
    BUNDLE_PATH=/gems \
    BUNDLE_BIN=/gems/bin \
    BUNDLE_APP_CONFIG=/gems \
    PATH=/gems/bin:$PATH

RUN set -ex \
  #
  # setup environment for normal user use gems
  #
  && sed -i s@'PATH="\(.*\)"'@'PATH="/gems/bin:\1"'@g /etc/profile \
  && mkdir -p $BUNDLE_BIN \
  && chown -R app. $GEM_HOME

WORKDIR $APP_HOME

ENTRYPOINT ["/usr/share/entrypoint.sh"]

CMD ["pry"]
