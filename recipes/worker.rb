 
# build the image (versus pulling it)

# directory node.deis.worker.checkout do
  # recursive true
  # action :create  
# end
# 
# git node.deis.worker.checkout do
  # repository node.deis.worker.repository
  # revision node.deis.worker.revision
  # action :checkout
# end
# 
# docker_image node.deis.worker.image do
  # source node.deis.worker.checkout
  # action :nothing
  # subscribes :build, "git[#{node.deis.worker.checkout}]", :immediately
  # cmd_timeout 600
# end

require 'etcd'

# TODO: refactor into library
ruby_block 'set-worker-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    client.set('/deis/controller/secret-key', 'CHANGEME_sapm$s%upvsw5l_zuy_&29rkywd^78ff(qilmw1#g')
    client.set('/deis/controller/builder-key', 'CHANGEME_sapm$s%upvsw5l_zuy_&29rkywd^78ff(qilmw1#g')
    client.set('/deis/controller/cm-module', 'cm.chef')
  end
  not_if {
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    begin
      client.get('/deis/controller')
      true
    rescue
      false
    end
  }
end

# TODO: refactor into library
env = []
ruby_block 'get-worker-config' do
  block do
    client = Etcd.client(host: node.deis.public_ip, port: node.deis.etcd.port)
    env.push("DATABASE_HOST='"+client.get('/deis/database/host').value+"'")
    env.push("DATABASE_USER='"+client.get('/deis/database/user').value+"'")
    env.push("DATABASE_PASSWORD='"+client.get('/deis/database/password').value+"'")
    env.push("DATABASE_NAME='"+client.get('/deis/database/name').value+"'")
    env.push("CACHE_HOST='"+client.get('/deis/cache/host').value+"'")
    env.push("CACHE_NAME='"+client.get('/deis/cache/name').value+"'")
    env.push("DEIS_SECRET_KEY='"+client.get('/deis/controller/secret-key').value+"'")
    env.push("DEIS_BUILDER_KEY='"+client.get('/deis/controller/builder-key').value+"'")
    env.push("DEIS_CM_MODULE='"+client.get('/deis/controller/cm-module').value+"'")
    # write out chef environment variables from node's global Chef::Config
    env.push("CHEF_SERVER_URL=#{Chef::Config[:chef_server_url]}")
    env.push("CHEF_CLIENT_NAME=#{Chef::Config[:node_name]}")
    env.push("CHEF_CLIENT_KEY=#{Base64.strict_encode64(File.read(Chef::Config[:client_key]))}")
    env.push("CHEF_VALIDATION_NAME=#{Chef::Config[:validation_client_name]}")
    env.push("CHEF_VALIDATION_KEY=#{Base64.strict_encode64(File.read(Chef::Config[:validation_key]))}")
    env.push("CHEF_NODE_NAME=#{Chef::Config[:node_name]}")
  end
end


# start the container and create an upstart service

docker_container node.deis.worker.container do
  container_name node.deis.worker.container
  detach true
  env env
  image node.deis.worker.image
  command 'celery worker --app=deis --loglevel=INFO'
  cmd_timeout 600 # image takes a while to download
end