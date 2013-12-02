#!/bin/bash
#
# Linode StackScript for the very basic initial configuration.
#
# Deploy it here https://manager.linode.com/stackscripts/index
# Latest version can be found here https://github.com/sgalashyn/linode-ubuntu
#
# <UDF name="host_name" Label="System host name" example="Some meaningful server identifier" />
# <UDF name="time_zone" Label="System time zone" default="US/Central" example="Set blank to keep defaults" />
# <UDF name="ssh_key" Label="SSH key to save to /root/id_rsa.pub" default="" example="Can be used by wizard.sh later" />
#

exec &> /root/StackScript.log

# Set the new default system hostname
echo $HOST_NAME > /etc/hostname
hostname -F /etc/hostname
# In 12.04+ both localhost and ubuntu are mapped to 127.0.01
sed -i "s/ubuntu/$HOST_NAME/" /etc/hosts
# Restart cron daemon to make sure it picked up the timezone change
service cron restart

# Set the proper timezone
if [ -n "$TIME_ZONE" ]
then
  echo "$TIME_ZONE" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi

# Save the SSH key (or create blank file)
if [ -n "$SSH_KEY" ]
then
  echo "$SSH_KEY" > /root/id_rsa.pub
fi

# Restrict the SSH locales to en_US only
sed -i "s/AcceptEnv/#AcceptEnv/" /etc/ssh/sshd_config
service ssh restart
dpkg-reconfigure locales
update-locale LANG=en_US.UTF-8
