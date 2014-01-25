
docker_image node.deis.server.image do
  source node.deis.server.source
  only_if "test -e #{node.deis.server.source}/Dockerfile"
  action :build
  cmd_timeout 600 # image takes a while to build
end

docker_container node.deis.server.container do
  container_name node.deis.server.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.server.port}"]
  image node.deis.server.image
  init_type false
  port "#{node.deis.server.port}:#{node.deis.server.port}"
  # bind mount /app if we're running out of vagrant
  volume File.exist?('/vagrant/manage.py') ? "/vagrant:/app/deis" : nil  
  cmd_timeout 600 # image takes a while to download
end

ruby_block 'wait-for-server' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/controller/host')
  end
end