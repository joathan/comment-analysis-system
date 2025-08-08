FROM ruby:2.7.6-slim

ENV RAILS_ENV=development \
  TZ=America/Maceio \
  BUNDLE_PATH=/gems \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  BUNDLE_FORCE_RUBY_PLATFORM=1 \
  BUNDLER_VERSION=2.4.22

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  build-essential git curl ca-certificates \
  libpq-dev pkg-config libffi-dev \
  nodejs npm tini \
  && npm install --global yarn@1 \
  && rm -rf /var/lib/apt/lists/*

RUN gem update --system 3.4.22 && \
  gem install bundler -v ${BUNDLER_VERSION}

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'test' && \
  bundle config set force_ruby_platform true && \
  bundle install

COPY docker/entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

COPY . .

EXPOSE 3000
ENTRYPOINT ["tini","--","entrypoint"]
CMD ["bundle","exec","rails","server","-b","0.0.0.0","-p","3000"]
