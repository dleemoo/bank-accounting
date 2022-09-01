ARG BUILDER_IMAGE

FROM $BUILDER_IMAGE AS builder

FROM builder

ARG APP_USER_ID \
    APP_GROUP_ID

ENV BUNDLE_PATH=/vendor \
    BUNDLE_BIN=/vendor/bin \
    APP_PATH=/app

MAINTAINER Leonardo Lobo Lima <dleemoo@gmail.com>

RUN set -eux \
  # setup basic environment to run as normal user
  && group_name=$(grep :x:$APP_GROUP_ID: /etc/group | cut -d: -f1) \
  && [ -n "$group_name" ] || { \
       addgroup --gid $APP_GROUP_ID dev && \
       group_name=dev; \
  } \ 
  && useradd --create-home --uid $APP_USER_ID --gid $group_name dev \
  && mkdir -p $APP_PATH $BUNDLE_BIN \
  && chown -R dev. $APP_PATH $BUNDLE_PATH \
  && sed -i s@'PATH="\(.*\)"'@'PATH="/vendor/bin:\1"'@g /etc/profile

USER dev

WORKDIR $APP_PATH
