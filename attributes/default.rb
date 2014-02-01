# base
default.deis.dir = '/var/lib/deis'
default.deis.username = 'deis'
default.deis.group = 'deis'
default.deis.log_dir = '/var/log/deis'
default.deis.public_ip = nil # public ip must be defined or discovered

# rsyslog
default.rsyslog.server_search = 'run_list:recipe\[deis\:\:controller\]'

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

# logger
default.deis.logger.image = 'deis/rsyslog'
default.deis.logger.source = '/vagrant/images/rsyslog'
default.deis.logger.container = 'deis-logger'
default.deis.logger.port = 514
default.deis.logger.user = 'syslog'
