FROM debian:latest
MAINTAINER Jeremy Botha

RUN apt-get update

# basics
RUN apt-get install -y openssl wget git gcc bzip2
RUN apt-get install -y libssl-dev libreadline-dev zlib1g-dev
RUN apt-get install --reinstall make

# add marionette user
RUN useradd -ms /bin/bash marionette

RUN mkdir /opt/util
RUN mkdir /home/marionette/rubies

# install ruby-install
RUN wget -O /opt/util/ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
RUN cd /opt/util && tar -xzvf ruby-install-0.7.0.tar.gz
RUN cd /opt/util/ruby-install-0.7.0/ && make install

# use ruby-install to install mri 2.5.1 to /home/marionette/rubies and grant her ownership of it
RUN ruby-install -i /home/marionette/rubies ruby 2.5.1
RUN chown -R marionette:marionette /home/marionette/rubies

# install path shim for rbenv
COPY .profile.sh /etc/profile.d/rbenv.path.sh

USER marionette
WORKDIR /home/marionette

# install rbenv for marionette
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY . ./

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]