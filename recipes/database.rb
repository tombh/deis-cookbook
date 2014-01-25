
docker_image node.deis.database.image do
  source node.deis.database.source
  only_if "test -e #{node.deis.database.source}/Dockerfile"
  action :build
end

docker_container node.deis.database.container do
  container_name node.deis.database.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.database.port}"]
  image node.deis.database.image
  init_type false
  port "#{node.deis.database.port}:#{node.deis.database.port}"
  # bind mount /app if we're running out of vagrant
  volume File.exist?('/vagrant/images/postgres') ? "/vagrant/images/postgres:/app" : nil  
end

ruby_block 'wait-for-database' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/database/host')
  end
end