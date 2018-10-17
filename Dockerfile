FROM ruby:2.5.1-stretch
MAINTAINER Jeremy Botha

# add marionette user
RUN useradd -ms /bin/bash marionette

RUN apt-get update
RUN apt-get install -y nodejs

RUN gem install bundler

USER marionette
WORKDIR /home/marionette

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 20 --retry 5 --deployment

COPY --chown=marionette:marionette . ./

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]