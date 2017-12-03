FROM ubuntu:latest
MAINTAINER Phill S <cereal7802@gmail.com>

RUN apt-get update
RUN apt-get -y upgrade

# Install apache, PHP, and supplimentary programs. 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 php libapache2-mod-php php-pear php-gd php-mysql php-mbstring php-curl php-json php-memcached unrar lame mediainfo subversion ffmpeg supervisor

# Install yenc for php
RUN wget https://github.com/niel/php-yenc/releases/download/v1.3.0/php7.0-yenc_1.3.0_amd64.deb && dpkg -i php7.0-yenc_1.3.0_amd64.deb && rm php7.0-yenc_1.3.0_amd64.deb

# Enable apache mods.
RUN a2enmod rewrite

# Manually set up the environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV path /:/var/www/newznab/www/
ENV SNVUSER settosvnuser
ENV SVNPASS settosvnpass
ENV CACHEOPT_METHOD none
ENV CACHEOPT_MEMCACHE_SERVER memcached
ENV CACHEOPT_MEMCACHE_PORT 11211
ENV DB_HOST mysql
ENV DB_PORT 3306
ENV DB_INNODB false
ENV DB_PCONNECT true

#add newznab processing script
ADD ./newznab.sh /newznab.sh

#Copy the setup script that downloads the latest release
COPY newznab-setup.sh /newznab-setup.sh

#Make newznab bash scripts in / executable
RUN chmod 755 /newznab*.sh

#Setup supervisor to start Apache and the Newznab scripts to load headers and build releases
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
COPY supervisor.newznab.conf /etc/supervisor/conf.d/newznab.conf

VOLUME /var/www/newznab
EXPOSE 80
WORKDIR /var/www/newznab/

#kickoff Supervisor to start the functions
CMD ["/usr/bin/supervisord"]
