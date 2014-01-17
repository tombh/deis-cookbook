
# configure the container unless its keyspace already exists

require 'etcd'

# TODO: refactor into library
env = []
ruby_block 'get-builder-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    env.push("CONTROLLER_HOST="+client.get('/deis/controller/host').value)
    env.push("CONTROLLER_PORT="+client.get('/deis/controller/port').value)
    env.push("BUILDER_KEY="+client.get('/deis/controller/builder-key').value)
    env.push("REGISTRY_HOST="+client.get('/deis/registry/host').value)
    env.push("REGISTRY_PORT="+client.get('/deis/registry/port').value)
  end
end

# TODO: refactor into library
ruby_block 'publish-builder' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/builder/host', node.deis.public_ip)
    client.set('/deis/builder/port', node.deis.builder.port)
  end
  action :nothing
end

# start the container and create an upstart service

docker_container node.deis.builder.container do
  container_name node.deis.builder.container
  detach true
  env env
  image node.deis.builder.image
  port "#{node.deis.builder.port}:22"
  cmd_timeout 600 # image takes a while to download
  privileged true
  #lxc_conf 'aa_profile=unconfined'
  notifies :create, "ruby_block[publish-builder]", :immediately
end

