
docker_container node.deis.worker.container do
  container_name node.deis.worker.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}"]
  image node.deis.worker.image
  init_type false
  # bind mount /app if we're running out of vagrant
  volume File.exist?('/vagrant/manage.py') ? "/vagrant:/app/deis" : nil
  cmd_timeout 600 # image takes a while to download
end