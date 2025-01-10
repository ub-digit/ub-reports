FROM ruby:2.7

WORKDIR /apps
COPY . /apps
# Must install bundler 2.4.22 due to the latest version of Bundler requires Ruby version >= 3.1
RUN gem install bundler -v 2.4.22
RUN bundle update --bundler
RUN bundle install
CMD bash
