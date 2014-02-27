
docker_image node.deis.worker.repository do
  repository node.deis.worker.repository
  tag node.deis.worker.tag
  action node.deis.dev.mode ? :pull_if_missing : :pull
  cmd_timeout node.deis.worker.image_timeout
end

docker_container node.deis.worker.container do
  container_name node.deis.worker.container
  detach true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}"]
  image "#{node.deis.worker.repository}:#{node.deis.worker.tag}"
  volume VolumeHelper.worker(node)
  cmd_timeout 600
end
