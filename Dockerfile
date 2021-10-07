FROM ruby:3.0.2-alpine

RUN apk --update add build-base nodejs tzdata postgresql-dev postgresql-client libxslt-dev libxml2-dev imagemagick
RUN set -eux \
    & apk add \
        --no-cache \
        nodejs \
        yarn


COPY . /app
ARG FURY_AUTH
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle config set gem.fury.io $FURY_AUTH && \
  bundle config set --local without 'development test' && \
  bundle install --jobs 5


COPY package.json .
COPY yarn.lock .
RUN yarn install
RUN yarn install --check-files

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8812

COPY . /app

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]