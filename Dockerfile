FROM ruby:2.6.6-alpine

ENV BUNDLER_VERSION=2.0.2

RUN apk add --update --no-cache --virtual build-deps \
      binutils-gold \
      build-base \
      curl \
      file \
      g++ \
      gcc \
      git \
      less \
      libstdc++ \
      libffi-dev \
      libc-dev \ 
      linux-headers \
      libxml2-dev \
      libxslt-dev \
      libgcrypt-dev \
      make \
      netcat-openbsd \
      nodejs \
      openssl \
      pkgconfig \
      postgresql-dev \
      python \
      tzdata \
      yarn \
      zip && rm -rf /var/lib/apk/*

RUN echo "precedence  2a04:4e42::0/32  5" >> /etc/gai.conf
RUN gem install bundler

ENV APP_HOME /app/wreeto
WORKDIR $APP_HOME
COPY Gemfile Gemfile.lock $APP_HOME/
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle check || bundle install --jobs 20 --retry 2
RUN apk del build-deps

COPY . $APP_HOME/
COPY config/database.docker.yml $APP_HOME/config/database.yml

RUN bundle exec rake assets:precompile

EXPOSE 8383

ENTRYPOINT ["./docker-entrypoint.sh"]
