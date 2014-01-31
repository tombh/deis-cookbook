
docker_container node.deis.worker.container do
  container_name node.deis.worker.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}"]
  image node.deis.worker.image
  init_type false
  # bind mount /app if we're running out of vagrant
  volume [ "/home/vagrant:/home/vagrant", File.exist?('/vagrant/manage.py') ? "/vagrant:/app/deis" : nil,
           File.exist?('/vagrant/images/worker') ? "/vagrant/images/worker/bin:/app/bin" : nil,
           File.exist?('/vagrant/images/worker') ? "/vagrant/images/worker/conf.d:/app/conf.d" : nil,
           File.exist?('/vagrant/images/worker') ? "/vagrant/images/worker/templates:/app/templates" : nil]
  cmd_timeout 600 # image takes a while to download
end