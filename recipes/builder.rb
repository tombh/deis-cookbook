
docker_image node.deis.builder.image do
  source node.deis.builder.source
  only_if "test -e #{node.deis.builder.source}/Dockerfile"
  action :build
end

docker_container node.deis.builder.container do
  container_name node.deis.builder.container
  detach true
  privileged true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.builder.port}"]
  image node.deis.builder.image
  init_type false  
  port "#{node.deis.builder.port}:22"
  # bind mount /app if we're running out of vagrant
  volume File.exist?('/vagrant/images/builder') ? "/vagrant/images/builder:/app" : nil
  cmd_timeout 600 # image takes a while to download
end

ruby_block 'wait-for-builder' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/builder/host')
  end
end