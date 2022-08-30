FROM debian:11.4-slim

MAINTAINER Leonardo Lobo Lima <dleemoo@gmail.com>

RUN set -ex \
  # add debian packages for essential runtime libraries
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
     apt-transport-https autoconf bash bison build-essential curl git less \
     libffi-dev libgdbm-dev libncurses-dev libreadline-dev libssl-dev \
     libyaml-dev pkg-config zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8 \
    PG_VERSION=14.5 \
    PG_DOWNLOAD_SHA256=90ead393dbc654cb0075eaaf0ec2058e6b9866ced478fed3cf2b68a5bc04eb24 \
    RUBY_MAJOR=3.1 \
    RUBY_VERSION=3.1.2 \
    RUBY_DOWNLOAD_SHA256=ca10d017f8a1b6d247556622c841fc56b90c03b1803f87198da1e4fd3ec3bf2a

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
  && rm -rf /tmp/postgresql* \
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
  # do not generate gem docs by default and setup env for normal user usage
  && mkdir -p /usr/local/etc && { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc \
  && rm -rf /tmp/ruby*
