
# start the container and create an upstart service

docker_container node.deis.etcd.container do
  container_name node.deis.etcd.container
  detach true
  env ["PUBLIC_IP=#{node.deis.public_ip}","ETCD_PORT=#{node.deis.etcd.port}"]
  image node.deis.etcd.image
  port ["#{node.deis.etcd.port}:#{node.deis.etcd.port}", 
        "#{node.deis.etcd.peer_port}:#{node.deis.etcd.peer_port}"]
end
  
# install etcdctl on the host

bash 'install-etcdctl' do
  cwd '/tmp'
  code <<-EOH
    wget -O etcd.tar.gz #{node.deis.etcd.url}
    tar xfz etcd.tar.gz
    mv etcd-v0.2.0-Linux-x86_64/etcdctl /usr/local/bin
    chown -R root:root /usr/local/bin/etcdctl
    rm -rf etcd.tar.gz etcd-v0.2.0-Linux-x86_64
    EOH
  creates '/usr/local/bin/etcdctl'
end
