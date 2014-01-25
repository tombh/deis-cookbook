
docker_image node.deis.cache.image do
  source node.deis.cache.source
  only_if "test -e #{node.deis.cache.source}/Dockerfile"
  action :build
end

docker_container node.deis.cache.container do
  container_name node.deis.cache.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.cache.port}"]
  image node.deis.cache.image
  init_type false
  # bind mount /app if we're running out of vagrant
  volume File.exist?('/vagrant/images/redis') ? "/vagrant/images/redis:/app" : nil  
  port "#{node.deis.cache.port}:#{node.deis.cache.port}"
end

ruby_block 'wait-for-cache' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/cache/host')
  end
end
