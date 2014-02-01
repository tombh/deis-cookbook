
docker_container node.deis.server.container do
  container_name node.deis.server.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.server.port}"]
  image node.deis.server.image
  init_type false
  port "#{node.deis.server.port}:#{node.deis.server.port}"
  volume [
          # share log directory between server and logger components
          # TODO: replace with a distributed mechanism for populating `deis logs`
          "#{node.deis.log_dir}:/app/deis/logs",
          # required by vagrant provider machinery
          '/home/vagrant:/home/vagrant',
          # bind mount /app if we're running out of vagrant
           File.exist?('/vagrant/manage.py') ? "/vagrant:/app/deis" : nil,
           File.exist?('/vagrant/images/server') ? "/vagrant/images/server/bin:/app/bin" : nil,
           File.exist?('/vagrant/images/server') ? "/vagrant/images/server/conf.d:/app/conf.d" : nil,
           File.exist?('/vagrant/images/server') ? "/vagrant/images/server/templates:/app/templates" : nil,]
  cmd_timeout 600 # image takes a while to download
end

ruby_block 'wait-for-server' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/controller/host')
  end
end