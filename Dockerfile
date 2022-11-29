FROM ruby:2.7

WORKDIR /apps
COPY . /apps
RUN gem install bundler
RUN bundle update --bundler
RUN bundle install
CMD bash
