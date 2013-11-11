#!/bin/bash
#
# System configuration and software setup utilities.
#
# Latest version can be found here https://github.com/sgalashyn/linode-ubuntu
#

# Update the system hostname and register it with hosts
function system_set_hostname {

  echo $1 > /etc/hostname

  sed -i "s/ubuntu/$1/" /etc/hosts

}

# Upgrade the system packages
function system_upgrade {

  apt-get update
  apt-get -y upgrade
  apt-get -y autoremove
  apt-get -y autoclean

}

# Configure the SSHD for maximum security
function system_setup_sshd {

  sed -i "s/^#*\(PermitRootLogin\).*/\1 no/" /etc/ssh/sshd_config
  sed -i "s/^#*\(PasswordAuthentication\).*/\1 no/" /etc/ssh/sshd_config
  sed -i "s/^#*\(UseDNS\).*/\1 no/" /etc/ssh/sshd_config

  echo "AllowGroups admin" >> /etc/ssh/sshd_config

  service ssh restart

}

# Configure the basic UFW rules
function system_setup_ufw {

  ufw logging on

  ufw default deny

  ufw allow ssh/tcp
  ufw limit ssh/tcp

  # TODO: use debconf-set-selections to avoid y/n question when on the SSH
  #echo "ufw " | debconf-set-selections

  ufw enable

}

# Init the Git repository for /etc
function system_init_git_etc {

  cd /etc
  git init
  git add .
  git commit -m "Commited initial status of /etc"
  chmod -R go-rwx .git

}

# Commit and annotate the pending changes to the /etc
function system_log_etc {

  if [ ! -n "$1" ]
  then
    MESSAGE="Committed recent /etc changes"
  else
    MESSAGE="$1"
  fi

  cd /etc
  git add .
  git commit -m "$MESSAGE"

}

# Create the primary unprivileged user and deploy the initial SSH key
function system_add_primary_user {

  GROUPNAME=`echo $1 | tr '[:upper:]' '[:lower:]'`
  USERNAME=`echo $2 | tr '[:upper:]' '[:lower:]'`
  PASSWORD=$3

  groupadd "$GROUPNAME" # additional group should be in sudoers (e.g. 'admin')

  useradd --create-home --shell "/bin/bash" --user-group --groups "$GROUPNAME" "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd

  sudo -u "$USERNAME" mkdir "/home/$USERNAME/.ssh"
  mv "$4" "/home/$USERNAME/.ssh/authorized_keys"
  chown "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh/authorized_keys"
  chmod 0600 "/home/$USERNAME/.ssh/authorized_keys"

}

# Install the useful software
function install_essentials {

  apt-get -y install python-software-properties \
  htop iotop subversion git-core git fail2ban denyhosts

  # Configure git credentials for current user (usually root)
  git config --global user.name "$1"
  git config --global user.email "$2"

}

# Install and tune the Apache
function install_apache {

  if [ ! -n "$1" ]
  then
    echo "install_apache() requires the RAM percent in the first argument"
    return 1;
  fi

  if [ ! -n "$2" ]
  then
    echo "install_apache() requires the user name in the second argument"
    return 1;
  fi

  apt-get -y install apache2 apache2-mpm-prefork

  a2dissite default default-ssl # disable the interfering default virtual hosts
  a2enmod ssl rewrite proxy # enable the useful modules

  # tune the memory usage: $1 is the percent of system memory to allocate towards Apache

  PERPROCMEM=10 # the amount of memory in MB each apache process is likely to utilize
  MEM=$(grep MemTotal /proc/meminfo | awk '{ print int($2/1024) }') # how much memory in MB this system has
  MAXCLIENTS=$((MEM*PERCENT/100/PERPROCMEM)) # calculate MaxClients
  MAXCLIENTS=${MAXCLIENTS/.*} # cast to an integer
  sed -i -e "s/\(^[ \t]*MaxClients[ \t]*\)[0-9]*/\1$MAXCLIENTS/" /etc/apache2/apache2.conf

  # hide the version info
  sed -i "s/^\(ServerTokens\).*/\1 Prod/" /etc/apache2/conf.d/security
  sed -i "s/^\(ServerSignature\).*/\1 Off/" /etc/apache2/conf.d/security

  # change the process user to primary one
  sed -i "s/www\-data/$2/g" /etc/apache2/envvars
  rm -rf /var/lock/apache2/

  service apache2 restart

  # allow the http requests on firewall
  ufw allow http/tcp
  ufw allow https/tcp

}

# TODO: functions for Apache virtual hosts (HTTP/HTTPS)
# NOTE: if using modern mod_cfml connector there's no need to configure the Tomcat vhosts

# Install and tune the MySQL
function install_mysql {

  if [ ! -n "$1" ]
  then
    echo "install_mysql() requires the root password in the first argument"
    return 1;
  fi

  echo "mysql-server-5.5 mysql-server/root_password password $1" | debconf-set-selections
  echo "mysql-server-5.5 mysql-server/root_password_again password $1" | debconf-set-selections
  apt-get -y install mysql-server mysql-client

  echo "Sleeping while MySQL starts up for the first time..."
  sleep 7

  # Cleanup the test database
  echo "DROP DATABASE test;" | mysql -u root -p$1

  return 1;

  # NOTE: this part of the function is incomplete, also see snippets.txt

  # tune the InnoDB configuration

  service mysql stop
  sleep 5

  # TODO: inject snippet before [mysqldump]

  service mysql start
  sleep 5

}

# Install and tune the PHP
function install_php {

  apt-get -y install php5 php5-mysql libapache2-mod-php5

  # let PHP use 32M per process
  sed -i'-orig' 's/memory_limit = [0-9]\+M/memory_limit = 32M/' /etc/php5/apache2/php.ini

  service apache2 restart

}

# Install the the Oracle JDK
function install_java {

  apt-add-repository -y ppa:webupd8team/java
  apt-get update > /dev/null

  echo "oracle-java7-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections

  apt-get install -y oracle-java7-installer

}

# Install the Railo server
function install_railo {

  # NOTE: this function is totally incomplete, also see snippets.txt

  return 1;

  # desired $1 version, $2 admin password, $3 system user name

  INSTALLER="railo-$1-pl0-linux-x64-installer.run"

  cd
  wget "http://www.getrailo.org/railo/remote/download/$1/tomcat/linux/$INSTALLER"

  chmod +x $INSTALLER

  ./$INSTALLER --mode unattended --railopass "$2" --systemuser "$3"
  # this key is pretty strange, it works partially
  #--apacheconfigloc /etc/apache2/railo.conf
  # TODO: set default context password?

  sudo /etc/init.d/railo_ctl stop

  # TODO: configure the JRE and memory settings

  # TODO: enable the IP addresses forwarding in web.conf

  # open the access to the Tomcat port from localhost (Apache proxy)
  ufw allow from 127.0.0.1 to any port 8888 proto tcp
  # alternatively, allow connections from everywhere
  #ufw allow 8888/tcp

}

#
