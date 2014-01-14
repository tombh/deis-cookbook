
# configure the container unless its keyspace already exists

require 'etcd'

# TODO: refactor into library
ruby_block 'set-database-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/database/engine', 'postgresql_psycopg2')
    client.set('/deis/database/admin-user', 'postgres')
    client.set('/deis/database/admin-pass', 'changeme123')
    client.set('/deis/database/user', 'deis')
    client.set('/deis/database/password', 'changeme123')
    client.set('/deis/database/name', 'deis')
  end
  not_if {
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    begin
      client.get('/deis/database')
      true
    rescue
      false
    end
  }
end

# TODO: refactor into library
env = []
ruby_block 'get-database-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    env.push("PG_ADMIN_USER="+client.get('/deis/database/admin-user').value)
    env.push("PG_ADMIN_PASS="+client.get('/deis/database/admin-pass').value)
    env.push("PG_USER_NAME="+client.get('/deis/database/user').value)
    env.push("PG_USER_PASS="+client.get('/deis/database/password').value)
    env.push("PG_USER_DB="+client.get('/deis/database/name').value)    
  end
end

# start the container and create an upstart service

docker_container node.deis.database.container do
  container_name node.deis.database.container
  detach true
  env env
  image node.deis.database.image
  port "#{node.deis.database.port}:#{node.deis.database.port}"
  cookbook 'deis'
  init_template 'deis-database.conf.erb'
end

# wait for the service to become active
