FROM debian:latest
MAINTAINER Jeremy Botha

RUN apt-get update

# basics
RUN apt-get install -y openssl

RUN wget -q https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer -O- | bash
RUN rbenv install 2.5.1

RUN mkdir /marionette
WORKDIR /marionette

COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY . ./

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]