name             'deis'
maintainer       'Gabriel Monroy'
maintainer_email 'gabriel@opdemand.com'
license          'Apache 2.0'
description      'Installs/Configures Deis PaaS Nodes'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.5.0'

depends          'apt'
depends          'docker'
depends          'sudo'
depends          'rsyslog'
