
# start the container and create an upstart service

docker_container node.deis.server.container do
  container_name node.deis.server.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.server.port}"]
  image node.deis.server.image
  port "#{node.deis.server.port}:#{node.deis.server.port}"
  cmd_timeout 600 # image takes a while to download
end