
docker_image node.deis.server.image do
  action :pull_if_missing
  cmd_timeout node.deis.server.image_timeout
end

docker_container node.deis.server.container do
  container_name node.deis.server.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.server.port}"]
  image node.deis.server.image
  port "#{node.deis.server.port}:#{node.deis.server.port}"
  volume VolumeHelper.server(node)
  cmd_timeout 600
end

ruby_block 'wait-for-server' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/controller/host')

    # Ensure that deis-server has development dependencies for running tests
    if node.deis.dev.mode == true
      output = `sudo /vagrant/contrib/vagrant/util/add_server_dev_deps.sh 2>&1`
      raise output if $?.exitstatus != 0
    end
  end
end
