
# configure the container unless its keyspace already exists

require 'etcd'

# TODO: refactor into library
ruby_block 'set-registry-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/registry/backend', 'local')
  end
  not_if {
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    begin
      client.get('/deis/registry')
      true
    rescue
      false
    end
  }
end

# TODO: refactor into library
env = []
ruby_block 'get-registry-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    env.push("REGISTRY_BACKEND="+client.get('/deis/registry/backend').value)
  end
end

# TODO: refactor into library
ruby_block 'publish-registry' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/registry/host', node.deis.public_ip)
    client.set('/deis/registry/port', node.deis.registry.port)
  end
  #action :nothing
end

# start the container and create an upstart service

# docker_container node.deis.registry.container do
  # container_name node.deis.registry.container
  # detach true
  # env env
  # image node.deis.registry.image
  # port "#{node.deis.registry.port}:#{node.deis.registry.port}"
  # notifies :create, "ruby_block[publish-registry]", :immediately
# end

