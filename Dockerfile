ARG RUBY_VER

FROM ruby:${RUBY_VER}-alpine

ARG APP_DIR

WORKDIR $APP_DIR

COPY Gemfile      ./
COPY Gemfile.lock ./

RUN apk add --update --no-cache build-base libpq postgresql-dev &&\
  gem install bundler &&\
  bundle config set without 'build' &&\
  bundle install &&\
  apk del build-base

COPY src/ ./

COPY ./version.txt ./

EXPOSE $UNICORN_PORT

CMD ["/bin/sh", "-c", "/usr/local/bundle/bin/unicorn -c ${APP_DIR}/unicorn.conf"]
