
# start the container and create an upstart service

docker_container node.deis.cache.container do
  container_name node.deis.cache.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=#{node.deis.cache.port}"]
  image node.deis.cache.image
  port "#{node.deis.cache.port}:#{node.deis.cache.port}"
end
