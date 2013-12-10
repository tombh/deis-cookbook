# base
default.deis.dir = '/opt/deis'
default.deis.username = 'deis'
default.deis.group = 'deis'
default.deis.log_dir = '/var/log/deis'
default.deis.devmode = false # set to true to disable repo syncing

# docker
default.deis.docker.key_url = 'https://get.docker.io/gpg'
default.deis.docker.deb_url = 'https://get.docker.io/ubuntu'
default.deis.docker.version = '0.7.1'

# database
default.deis.database.name = 'deis'
default.deis.database.user = 'deis'

# server/api
default.deis.controller.dir = '/opt/deis/controller'
default.deis.controller.repository = 'https://github.com/opdemand/deis.git'
default.deis.controller.revision = 'master'
default.deis.controller.debug = 'False'
default.deis.controller.workers = 4
default.deis.controller.worker_port = 8000
default.deis.controller.http_port = 80
default.deis.controller.https_port = 443
default.deis.controller.log_dir = '/opt/deis/controller/logs'

# gitosis
default.deis.gitosis.dir = '/opt/deis/gitosis'
default.deis.gitosis.repository = 'git://github.com/opdemand/gitosis.git'
default.deis.gitosis.revision = 'master'

# build
default.deis.build.dir = '/opt/deis/build'
default.deis.build.slug_dir = '/opt/deis/build/slugs'
default.deis.build.builder_dir = '/opt/deis/build/slugbuilder'
default.deis.build.repository = 'https://github.com/flynn/slugbuilder'
default.deis.build.revision = 'master'

# runtime
default.deis.runtime.dir = '/opt/deis/runtime'
default.deis.runtime.runner_dir = '/opt/deis/runtime/slugrunner'
default.deis.runtime.slug_dir = '/opt/deis/runtime/slugs'
default.deis.runtime.repository = 'https://github.com/flynn/slugrunner'
default.deis.runtime.revision = 'master'

# rsyslog
default['rsyslog']['log_dir'] = '/var/log/rsyslog'
default['rsyslog']['protocol'] = 'tcp'
default['rsyslog']['port'] = 514
default['rsyslog']['server_search'] = 'run_list:recipe\[deis\:\:controller\]'
default['rsyslog']['per_host_dir'] = '%HOSTNAME%'

