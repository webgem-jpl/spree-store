FROM ruby:3.0.2-alpine

RUN apk --update add build-base nodejs tzdata postgresql-dev postgresql-client libxslt-dev libxml2-dev imagemagick
RUN set -eux \
    & apk add \
        --no-cache \
        nodejs \
        yarn \
        git


ARG BUNDLE_GITHUB__COM
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle config set --local without 'development test' && \
  bundle install --jobs 4 --retry 3

COPY package.json .
COPY yarn.lock .
RUN yarn install --check-files

Copy . /app 

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [""]
EXPOSE 8812

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0","-e","production"]