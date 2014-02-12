
docker_image node.deis.database_data.image do
  action :pull
  cmd_timeout node.deis.database_data.image_timeout
end

docker_container node.deis.database_data.container do
  container_name node.deis.database_data.container
  detach true
  image node.deis.database_data.image
  volume VolumeHelper.database_data(node)
end

docker_image node.deis.database.image do
  action :pull
  cmd_timeout node.deis.database.image_timeout
end

docker_container node.deis.database.container do
  container_name node.deis.database.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.database.port}"]
  image node.deis.database.image
  port "#{node.deis.database.port}:#{node.deis.database.port}"
  volume VolumeHelper.database(node)
  volumes_from node.deis.database_data.container
end

ruby_block 'wait-for-database' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/database/host')
  end
end
