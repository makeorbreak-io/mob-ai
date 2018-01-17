FROM ruby:2.5.0-alpine3.7

RUN apk add --update musl-dev gcc make && DISABLE_SSL=true gem install sinatra puma && apk del musl-dev gcc make && rm -rf /var/cache/apk/*
