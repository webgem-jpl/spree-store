FROM ruby:3.0.2
RUN apt-get update && apt-get install -y \
  curl \
  build-essential \
  libpq-dev &&\
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn

ARG FURY_AUTH
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bash -c 'echo $FURY_AUTH'
RUN bundle config set gem.fury.io $FURY_AUTH
RUN bundle install


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