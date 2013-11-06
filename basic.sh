#!/bin/bash
#
# Basic configuration for the first root login.
# Used as a Linode StackScript https://manager.linode.com/stackscripts/index
#
# <UDF name="time_zone" Label="System time zone" default="US/Central" />
#

exec &> /root/stackscript.log

# Restrict the SSH locales to en_US only
sed -i "s/AcceptEnv/#AcceptEnv/" /etc/ssh/sshd_config
service ssh restart
dpkg-reconfigure locales
update-locale LANG=en_US.UTF-8

# Set the proper timezone
echo "$TIME_ZONE" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Make sure system is already up to date on the 1st login
apt-get update
apt-get -y upgrade
