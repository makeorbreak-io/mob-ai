FROM ruby:2.5.0-alpine3.7

RUN apk add --update docker git

WORKDIR /ai-competition
ADD . /ai-competition
RUN bundle install --without=webserver
