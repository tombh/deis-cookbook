# base
default.deis.dir = '/var/lib/deis'
default.deis.username = 'deis'
default.deis.group = 'deis'
default.deis.log_dir = '/var/log/deis'
default.deis.public_ip = nil  # public ip must be defined or discovered
default.deis.image_timeout = 300

# development
default.deis.dev.mode = false
default.deis.dev.source = '/vagrant'

# rsyslog
default.rsyslog.server_search = 'run_list:recipe\[deis\:\:controller\]'

# discovery
default.deis.etcd.repository = 'deis/discovery'
default.deis.etcd.tag = 'v0.1.0'
default.deis.etcd.image_timeout = default.deis.image_timeout
default.deis.etcd.source = '/vagrant/images/discovery'
default.deis.etcd.container = 'deis-discovery'
default.deis.etcd.port = 4001
default.deis.etcd.peer_port = 7001
default.deis.etcd.url = 'https://github.com/coreos/etcd/releases/download/v0.3.0/etcd-v0.3.0-linux-amd64.tar.gz'

# database
default.deis.database.repository = 'deis/database'
default.deis.database.tag = 'v0.1.1'
default.deis.database.image_timeout = default.deis.image_timeout
default.deis.database.source = '/vagrant/images/database'
default.deis.database.container = 'deis-database'
default.deis.database.port = 5432

# database-data
default.deis.database_data.repository = 'deis/data'
default.deis.database_data.tag = 'latest'
default.deis.database_data.image_timeout = default.deis.image_timeout
default.deis.database_data.container = 'deis-database-data'

# cache
default.deis.cache.repository = 'deis/cache'
default.deis.cache.tag = 'v0.1.1'
default.deis.cache.image_timeout = default.deis.image_timeout
default.deis.cache.source = '/vagrant/images/cache'
default.deis.cache.container = 'deis-cache'
default.deis.cache.port = 6379

# server
default.deis.server.repository = 'deis/server'
default.deis.server.tag = 'v0.1.1'
default.deis.server.image_timeout = default.deis.image_timeout * 2
default.deis.server.source = '/vagrant/images/server'
default.deis.server.container = 'deis-server'
default.deis.server.port = 8000

# worker
default.deis.worker.repository = 'deis/worker'
default.deis.worker.tag = 'v0.1.1'
default.deis.worker.image_timeout = default.deis.image_timeout * 2
default.deis.worker.source = '/vagrant/images/worker'
default.deis.worker.container = 'deis-worker'

# registry
default.deis.registry.repository = 'deis/registry'
default.deis.registry.tag = 'v0.1.2'
default.deis.registry.image_timeout = default.deis.image_timeout * 2
default.deis.registry.source = '/vagrant/images/registry'
default.deis.registry.container = 'deis-registry'
default.deis.registry.port = 5000

# registry-data
default.deis.registry_data.repository = 'deis/data'
default.deis.registry_data.tag = 'latest'
default.deis.registry_data.image_timeout = 300
default.deis.registry_data.container = 'deis-registry-data'

# builder
default.deis.builder.repository = 'deis/builder'
default.deis.builder.tag = 'v0.1.2'
default.deis.builder.image_timeout = default.deis.image_timeout
default.deis.builder.source = '/vagrant/images/builder'
default.deis.builder.container = 'deis-builder'
default.deis.builder.port = 2222
# change nil to target diractory to sync buildpacks from github
default.deis.builder.packs = nil #'/var/lib/deis/buildpacks'

# logger
default.deis.logger.repository = 'deis/logger'
default.deis.logger.tag = 'v0.1.1'
default.deis.logger.image_timeout = default.deis.image_timeout
default.deis.logger.source = '/vagrant/images/logger'
default.deis.logger.container = 'deis-logger'
default.deis.logger.port = 514
default.deis.logger.user = 'syslog'
