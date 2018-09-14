FROM 056154071827.dkr.ecr.us-east-1.amazonaws.com/base-image-ruby-version-arg:2.4
MAINTAINER cru.org <wmd@cru.org>

ARG SIDEKIQ_CREDS
ARG RAILS_ENV=production

COPY Gemfile Gemfile.lock ./

RUN bundle config gems.contribsys.com $SIDEKIQ_CREDS
RUN bundle install --jobs 20 --retry 5 --path vendor
RUN bundle binstub puma sidekiq rake

COPY . ./

ARG BASE_URL=http://localhost:3000
ARG CAS_URL=https://thekey.me/cas
ARG CAS_ACCESS_TOKEN=test
ARG DB_ENV_POSTGRESQL_USER=postgres
ARG DB_ENV_POSTGRESQL_PASS=
ARG DB_ENV_POSTGRESQL_DB=cru
ARG DB_PORT_5432_TCP_ADDR=localhost
ARG REDIS_PORT_6379_TCP_ADDR=localhost
ARG REDIS_PORT_6379_TCP_PORT=6379
ARG NEWRELIC_KEY=test
RUN bundle exec rake assets:precompile RAILS_ENV=production

## Run this last to make sure permissions are all correct
RUN mkdir -p /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads && \
  chmod -R ugo+rw /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads