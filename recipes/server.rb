
docker_image node.deis.server.image

docker_container node.deis.server.container do
  container_name node.deis.server.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.server.port}"]
  image node.deis.server.image
  init_type false
  port "#{node.deis.server.port}:#{node.deis.server.port}"
  volume VolumeHelper.server(node)
  cmd_timeout 600 # image takes a while to download
end

ruby_block 'wait-for-server' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/controller/host')
  end
end
