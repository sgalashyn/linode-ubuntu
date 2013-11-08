## Description

Scripts for managing the Ubuntu servers on the Linode.

Many functions are inspired by Linode StackScripts and excellent Linode documentation.

Significant part of configuration is currently hardcoded and reflects author's personal preferences.
Eventually all of the options should become externally configurable.

## Scripts Included

* basic.sh -- Linode StackScript for the very basic initial configuration.
* library.sh -- System configuration and software setup utilities.
* wizard.sh -- Setup runner script which executes the selected commands.

## Usage Examples

Grab the scripts:

    wget https://github.com/sgalashyn/linode-ubuntu/archive/master.zip
    unzip master.zip

Edit the configuration:

    cd linode-ubuntu-master
    vim wizard.sh

Run the wizard:

    ./wizard.sh

Reboot the node to pick the new hostname. Login as regular user to continue the setup.

## Roadmap

1. Add the functions for MySQL tuning, Apache hosts,
1. Add the functions for Railo, Tomcat hosts.
1. Add the functions for Trac with Apache, SVN with Apache.
1. Implement the wizard.sh arguments support (getopts).
1. Improve the flexibility and input data validation of the functions.
1. Document the usage properly with ready-to-use examples.
1. Add the functions for Node.js and Grunt.js.
1. Consider splitting the library and use only selected parts.
1. Add the function for Tomcat upgrade in the Railo installation.
1. Add the functions for cron jobs handling.

## Useful Links

* [Linode Library](https://library.linode.com/)
* [Linode StackScripts](https://library.linode.com/stackscripts)
* [Installing Oracle JDK in Ubuntu via PPA](http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html)
* [InnoDB performance optimization basics](http://www.mysqlperformanceblog.com/2013/09/20/innodb-performance-optimization-basics-updated/)
* [Railo at GitHub](https://github.com/getrailo/railo)
* [Railo at Google Groups](https://groups.google.com/forum/#!forum/railo)

## License

Code is released under the [Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
