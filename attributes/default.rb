# base
default.deis.dir = '/var/lib/deis'
default.deis.username = 'deis'
default.deis.group = 'deis'
default.deis.log_dir = '/var/log/deis'
default.deis.devmode = false # set to true to disable repo syncing
default.deis.public_ip = nil # public ip must be defined in most cases

# docker
default.deis.docker.key_url = 'https://get.docker.io/gpg'
default.deis.docker.deb_url = 'https://get.docker.io/ubuntu'
default.deis.docker.version = '0.7.6'

# etcd
default.deis.etcd.image = 'deis/etcd'
default.deis.etcd.source = '/vagrant/images/etcd'
default.deis.etcd.container = 'deis-etcd'
default.deis.etcd.port = 4001
default.deis.etcd.peer_port = 7001
default.deis.etcd.url = 'https://github.com/coreos/etcd/releases/download/v0.2.0/etcd-v0.2.0-Linux-x86_64.tar.gz'

# database
default.deis.database.image = 'deis/postgres'
default.deis.database.source = '/vagrant/images/postgres'
default.deis.database.container = 'deis-database'
default.deis.database.port = 5432

# cache
default.deis.cache.image = 'deis/redis'
default.deis.cache.source = '/vagrant/images/redis'
default.deis.cache.container = 'deis-cache'
default.deis.cache.port = 6379

# server
default.deis.server.image = 'deis/server'
default.deis.server.source = '/vagrant/images/server'
default.deis.server.container = 'deis-server'
default.deis.server.port = 8000

# worker
default.deis.worker.image = 'deis/worker'
default.deis.worker.source = '/vagrant/images/worker'
default.deis.worker.container = 'deis-worker'

# registry
default.deis.registry.image = 'deis/registry'
default.deis.registry.source = '/vagrant/images/registry'
default.deis.registry.container = 'deis-registry'
default.deis.registry.port = 5000

# builder
default.deis.builder.image = 'deis/builder'
default.deis.builder.source = '/vagrant/images/builder'
default.deis.builder.container = 'deis-builder'
default.deis.builder.port = 2222
default.deis.builder.packs = '/var/lib/deis/buildpacks'

# # server/api
# default.deis.controller.dir = '/opt/deis/controller'
# default.deis.controller.repository = 'https://github.com/opdemand/deis.git'
# default.deis.controller.revision = 'master'
# default.deis.controller.debug = 'False'
# default.deis.controller.workers = 4
# default.deis.controller.worker_port = 8000
# default.deis.controller.http_port = 80
# default.deis.controller.https_port = 443
# default.deis.controller.log_dir = '/opt/deis/controller/logs'
#
# # gitosis
# default.deis.gitosis.dir = '/opt/deis/gitosis'
# default.deis.gitosis.repository = 'git://github.com/opdemand/gitosis.git'
# default.deis.gitosis.revision = 'master'
# 
# # build
# default.deis.build.dir = '/opt/deis/build'
# default.deis.build.slug_dir = '/opt/deis/build/slugs'
# default.deis.build.pack_dir = '/opt/deis/build/packs'
# default.deis.build.builder_dir = '/opt/deis/build/slugbuilder'
# default.deis.build.repository = 'https://github.com/flynn/slugbuilder'
# default.deis.build.revision = 'master'
# 
# # runtime
# default.deis.runtime.dir = '/opt/deis/runtime'
# default.deis.runtime.runner_dir = '/opt/deis/runtime/slugrunner'
# default.deis.runtime.slug_dir = '/opt/deis/runtime/slugs'
# default.deis.runtime.repository = 'https://github.com/flynn/slugrunner'
# default.deis.runtime.revision = 'master'

# rsyslog
default['rsyslog']['log_dir'] = '/var/log/rsyslog'
default['rsyslog']['protocol'] = 'tcp'
default['rsyslog']['port'] = 514
default['rsyslog']['server_search'] = 'run_list:recipe\[deis\:\:controller\]'
default['rsyslog']['per_host_dir'] = '%HOSTNAME%'

