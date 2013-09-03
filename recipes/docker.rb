
include_recipe 'apt'

apt_repository 'dotcloud' do
  key node['deis']['docker']['key_url']
  uri node['deis']['docker']['deb_url']
  distribution 'docker'
  components ['main']
end

package 'lxc-docker' do
  version node['deis']['docker']['version']
end

service 'docker' do
  provider Chef::Provider::Service::Upstart  
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end
