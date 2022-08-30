FROM debian:11.4-slim

MAINTAINER Leonardo Lobo Lima <dleemoo@gmail.com>

RUN set -ex \
  # add debian packages for essential runtime libraries
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
     apt-transport-https autoconf bash bison build-essential curl git less \
     libffi-dev libgdbm-dev libncurses-dev libreadline-dev libssl-dev \
     libyaml-dev pkg-config zlib1g-dev

ARG APP_USER_ID \
    APP_GROUP_ID

ENV LANG=C.UTF-8 \
    APP_HOME=/app \
    APP_USER_HOME=/home/dev \
    GOSU_DOWNLOAD_SHA256=bd8be776e97ec2b911190a82d9ab3fa6c013ae6d3121eea3d0bfd5c82a0eaf8c \
    ENTRYPOINT_SHA256=a3e8beda15e6474559e85b81811eafab94bc3213a00da124a93002511bc2ed8f

RUN set -eux \
  #
  # Basic setup (packages) and entrypoint for use container as normal user
  #
  # files to run container as normal user
  && curl -sfL https://bit.ly/3Q1sDK7 -o /usr/share/entrypoint.sh \
  && curl -sfL https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64 -o /usr/local/bin/gosu \
  # check files integrity
  && echo "$GOSU_DOWNLOAD_SHA256 /usr/local/bin/gosu" | sha256sum -c - \
  && echo "$ENTRYPOINT_SHA256 /usr/share/entrypoint.sh" | sha256sum -c - \
  # setup basic environment to run as normal user and use /gems/bin
  && mkdir -p $APP_HOME $APP_USER_HOME \
  && chmod +x /usr/share/entrypoint.sh /usr/local/bin/gosu \
  && group_name=$(grep :x:$APP_GROUP_ID: /etc/group | cut -d: -f1) \
  && [ -n "$group_name" ] || addgroup --gid $APP_GROUP_ID dev \
  && [ -n "$group_name" ] || group_name=dev \
  && useradd --create-home --uid $APP_USER_ID --gid $group_name dev \
  && chown -R dev. $APP_HOME $APP_USER_HOME \
  # clean up apt files
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV PG_VERSION=14.5 \
    PG_DOWNLOAD_SHA256=90ead393dbc654cb0075eaaf0ec2058e6b9866ced478fed3cf2b68a5bc04eb24

RUN set -ex \
  #
  # setup postgres client libs and headers
  #
  && curl -sL http://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz -o /tmp/postgresql.tar.gz \
  && echo "$PG_DOWNLOAD_SHA256 /tmp/postgresql.tar.gz" | sha256sum -c - \
  && mkdir -p /tmp/postgresql \
  && tar -xzf /tmp/postgresql.tar.gz -C /tmp/postgresql --strip-components=1 \
  && cd /tmp/postgresql \
  && CFLAGS="-O3 -pipe" ./configure --prefix=/usr/local 1>/dev/null \
  && make -j"$(getconf _NPROCESSORS_ONLN)" \
  && make -j"$(getconf _NPROCESSORS_ONLN)" -C src/include install \
  && make -j"$(getconf _NPROCESSORS_ONLN)" -C src/bin install \
  && make -j"$(getconf _NPROCESSORS_ONLN)" -C src/interfaces install \
  && cd /tmp \
  && rm -rf /tmp/postgresql*

ENV RUBY_MAJOR=3.1 \
    RUBY_VERSION=3.1.2 \
    RUBY_DOWNLOAD_SHA256=ca10d017f8a1b6d247556622c841fc56b90c03b1803f87198da1e4fd3ec3bf2a

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
  && chown -R dev. $GEM_HOME

WORKDIR $APP_HOME

ENTRYPOINT ["/usr/share/entrypoint.sh"]

CMD ["pry"]
