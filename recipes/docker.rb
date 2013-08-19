
include_recipe 'apt'

apt_repository 'docker-ppa' do
  uri 'http://ppa.launchpad.net/dotcloud/lxc-docker/ubuntu'
  distribution node.lsb.codename
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key node['deis']['docker']['key']
end

package 'lxc-docker' do
  version node['deis']['docker']['version']
end

service 'docker' do
  provider Chef::Provider::Service::Upstart  
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end
