#!/bin/sh

echo "Setup the Shuttle system in Ubuntu"

# Update the system
sudo apt-get -y update
sudo apt-get -y install curl chkconfig git-core nodejs ruby1.9.1 ruby1.9.1-dev make 
sudo apt-get -y install python-software-properties postgresql libarchive12 libarchive-dev g++ libpq-dev postgresql-contrib
#sudo apt-get -y install openjdk-7-jdk

# Install the Ruby 1.9
sudo gem1.9.1 install rubygems-bundler 
sudo gem1.9.1 install bundler
sudo gem1.9.1 install rake
sudo gem1.9.1 install rails 
sudo gem1.9.1 install libarchive -v '0.1.2'

# Install Redis
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make 
sudo make install
sudo ln -s /usr/local/bin/redis-cli /usr/bin/redis-cli 
sudo ln -s /usr/local/bin/redis-server /usr/bin/redis-server
sudo ln -s /usr/local/bin/redis-check-dump /usr/bin/redis-check-dump
sudo ln -s /usr/local/bin/redis-check-aof /usr/bin/redis-check-aof
sudo ln -s /usr/local/bin/redis-benchmark /usr/bin/redis-benchmark 

sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis/

cd ~
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.7.deb
dpkg -i elasticsearch-0.90.7.deb

sudo service postgresql start 
sudo service redis-server start
sudo service elasticsearch start 
sudo chkconfig redis-server on
sudo chkconfig elasticsearch on
sudo chkconfig postgresql on

# Import the database settings
sudo -u postgres -- sh -c "createuser shuttle; createdb -O shuttle shuttle_development; createdb -O shuttle shuttle_test"

cd ~
git clone https://github.com/square/shuttle.git

cd shuttle
sudo bundle install
sudo rake db:migrate db:seed
export RAILS_ENV=test rake db:migrate
sudo rspec spec

