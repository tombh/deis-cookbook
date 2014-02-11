
docker_image node.deis.worker.image do
  action :pull
  cmd_timeout node.deis.worker.image_timeout
end

docker_container node.deis.worker.container do
  container_name node.deis.worker.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}"]
  image node.deis.worker.image
  init_type "upstart"
  volume VolumeHelper.worker(node)
  cmd_timeout 600
end
