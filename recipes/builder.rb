
# configure the container unless its keyspace already exists

require 'etcd'

# # TODO: refactor into library
# ruby_block 'set-builder-config' do
  # block do
    # client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    # client.set('/deis/builder/port', '5000')
    # client.set('/deis/cache/name', '0')
  # end
  # not_if {
    # client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    # begin
      # client.get('/deis/cache')
      # true
    # rescue
      # false
    # end
  # }
# end

# TODO: refactor into library
env = []
ruby_block 'get-builder-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    env.push("CONTROLLER_HOST="+client.get('/deis/controller/host').value)
    env.push("CONTROLLER_PORT="+client.get('/deis/controller/port').value)
    env.push("BUILDER_KEY="+client.get('/deis/controller/builder-key').value)
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

