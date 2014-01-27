
docker_container node.deis.registry.container do
  container_name node.deis.registry.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.registry.port}"]
  image node.deis.registry.image
  init_type false  
  port "#{node.deis.registry.port}:#{node.deis.registry.port}"
  # bind mount /app if we're running out of vagrant
  volume File.exist?('/vagrant/images/registry') ? "/vagrant/images/registry:/app" : nil
  cmd_timeout 600 # image takes a while to download
end

ruby_block 'wait-for-registry' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/registry/host')
  end
end