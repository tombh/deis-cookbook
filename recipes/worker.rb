
docker_image node.deis.worker.image

docker_container node.deis.worker.container do
  container_name node.deis.worker.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}"]
  image node.deis.worker.image
  init_type false
  volume VolumeHelper.worker(node)
  cmd_timeout 600 # image takes a while to download
end