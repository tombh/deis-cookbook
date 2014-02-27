
docker_image node.deis.server.repository do
  repository node.deis.server.repository
  tag node.deis.server.tag
  action node.deis.dev.mode ? :pull_if_missing : :pull
  cmd_timeout node.deis.server.image_timeout
end

docker_container node.deis.server.container do
  container_name node.deis.server.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.server.port}"]
  image "#{node.deis.server.repository}:#{node.deis.server.tag}"
  port "#{node.deis.server.port}:#{node.deis.server.port}"
  volume VolumeHelper.server(node)
  cmd_timeout 600
end

ruby_block 'wait-for-server' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/controller/host')
  end
end
