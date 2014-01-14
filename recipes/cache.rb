
# configure the container unless its keyspace already exists

require 'etcd'

# TODO: refactor into library
ruby_block 'set-cache-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/cache/port', '6379')
    client.set('/deis/cache/name', '0')
  end
  not_if {
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    begin
      client.get('/deis/cache')
      true
    rescue
      false
    end
  }
end

# TODO: refactor into library
env = []
ruby_block 'get-cache-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    env.push("CACHE_PORT="+client.get('/deis/cache/port').value)
    env.push("CACHE_NAME="+client.get('/deis/cache/name').value)
  end
end

# TODO: refactor into library
ruby_block 'publish-cache-host' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/cache/host', node.deis.public_ip)
  end
  not_if {
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    begin
      client.get('/deis/cache/host')
      true
    rescue
      false
    end
  }
  action :nothing
end

# start the container and create an upstart service

docker_container node.deis.cache.container do
  container_name node.deis.cache.container
  detach true
  env env
  image node.deis.cache.image
  port "#{node.deis.cache.port}:#{node.deis.cache.port}"
  notifies :create, "ruby_block[publish-cache-host]", :immediately
end

