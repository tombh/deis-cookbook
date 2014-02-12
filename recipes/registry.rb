
docker_image node.deis.registry_data.image do
  action :pull_if_missing
  cmd_timeout node.deis.registry_data.image_timeout
end

docker_container node.deis.registry_data.container do
  container_name node.deis.registry_data.container
  detach true
  init_type false
  image node.deis.registry_data.image
  volume VolumeHelper.registry_data(node)
end

docker_image node.deis.registry.image do
  action :pull_if_missing
  cmd_timeout node.deis.registry.image_timeout
end

docker_container node.deis.registry.container do
  container_name node.deis.registry.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.registry.port}"]
  image node.deis.registry.image
  port "#{node.deis.registry.port}:#{node.deis.registry.port}"
  volume VolumeHelper.registry(node)
  cmd_timeout 600
end

ruby_block 'wait-for-registry' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/registry/host', seconds=60)
  end
end
