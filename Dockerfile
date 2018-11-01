FROM r-base:3.5.1
MAINTAINER David Charte <fdavidcl@protonmail.com>

ENV BUILD_PACKAGES bash curl ruby-dev build-essential libffi-dev libxml2-dev libssl-dev libcurl4-openssl-dev nano inotify-tools
ENV RUBY_PACKAGES ruby ruby-bundler

# Update and install all of the required packages.
# At the end, remove the package cache
RUN apt-get update && \
    apt-get install -y --no-install-recommends $BUILD_PACKAGES $RUBY_PACKAGES && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/app
WORKDIR /usr/app

# Install Ruby dependencies
COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle install --frozen

# Install R dependencies
RUN mkdir /usr/app/bin
COPY bin/r_install /usr/app/bin
RUN /usr/app/bin/r_install mldr jsonlite && \
    rm -rf /tmp/*/downloaded_packages

# Copy and run app
COPY . /usr/app

EXPOSE 80

ENTRYPOINT /usr/app/init.sh