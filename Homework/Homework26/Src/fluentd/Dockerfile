FROM fluent/fluentd:v1.18.0-debian-1.0

USER root

RUN gem install elasticsearch --no-document --version 8.19.0 \
    && gem install fluent-plugin-elasticsearch --no-document --version 5.4.3

USER fluent