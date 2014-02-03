
docker_image node.deis.logger.image do
  action :pull
end

docker_container node.deis.logger.container do
  container_name node.deis.logger.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.logger.port}"]
  image node.deis.logger.image
  init_type false
  volume VolumeHelper.logger(node)
  port "#{node.deis.logger.port}:#{node.deis.logger.port}"
end

ruby_block 'wait-for-logger' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/logs/host')
  end
end
