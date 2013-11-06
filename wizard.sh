#!/bin/bash
#
# Setup runner script which executes the selected commands.
#

# Configuration

HOST_NAME=""

USER_GROUP="admin"
USER_NAME=""
USER_PASS=""
KEY_FILE="/root/id_rsa.pub"

GIT_USER="root"
GIT_EMAIL="root@$HOST_NAME"

SETUP_APACHE="No"
APACHE_RAM="40"

SETUP_MYSQL="No"
MYSQL_PASS=""
MYSQL_RAM="40"

SETUP_PHP="No"

SETUP_JAVA="No"

# Include the libraries

source "library.sh"

# Launch the sequence

system_upgrade

install_essentials

system_init_git_etc

system_set_hostname $HOST_NAME
system_log_etc "Set the hostname to $HOST_NAME"

system_setup_sshd
system_log_etc "Configured the sshd"

system_setup_ufw
system_log_etc "Configured the ufw"

system_add_primary_user $USER_GROUP $USER_NAME $USER_PASS $KEY_FILE
system_log_etc "Created the primary user $USER_NAME"

if [ "$SETUP_APACHE" == "Yes" ]; then
  install_apache $APACHE_RAM $USER_NAME
  system_log_etc "Installed the Apache"
fi

if [ "$SETUP_MYSQL" == "Yes" ]; then
  install_mysql $MYSQL_PASS $MYSQL_RAM
  system_log_etc "Installed the MySQL"
fi

if [ "$SETUP_PHP" == "Yes" ]; then
  install_php
  system_log_etc "Installed the PHP"
fi

if [ "$SETUP_JAVA" == "Yes" ]; then
  install_java
  system_log_etc "Installed the Java"
fi
