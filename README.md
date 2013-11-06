## Description

Scripts for managing the Ubuntu servers on the Linode.

Many functions are inspired by Linode StackScripts and excellent Linode documentation.

Significant part of configuration is currently hardcoded and reflects author's personal preferences.
Eventually all of the options should become externally configurable.

## Scripts Included

* basic.sh -- Linode StackScript for the very basic initial configuration.
* library.sh -- System configuration and software setup utilities.
* wizard.sh -- Setup runner script which executes the selected commands.

## Roadmap

1. Add the functions for MySQL tuning, Apache hosts,
1. Add the functions for Railo, Tomcat hosts.
1. Add the functions for Trac with Apache, SVN with Apache.
1. Implement the wizard.sh arguments support (getopts).
1. Improve the flexibility and input data validation of the functions.
1. Document the usage properly with ready-to-use examples.
1. Add the functions for Node.js and Grunt.js.
1. Consider splitting the library and use only selected parts.

## Useful Links

* [Linode Library](https://library.linode.com/)
* [Linode StackScripts](https://library.linode.com/stackscripts)
* [Installing Oracle JDK in Ubuntu via PPA](http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html)

## License

Code is released under the [Apache License Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
