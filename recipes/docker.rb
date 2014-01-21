
include_recipe 'apt'

apt_repository 'dotcloud' do
  key node['deis']['docker']['key_url']
  uri node['deis']['docker']['deb_url']
  distribution 'docker'
  components ['main']
  not_if { File.exists?('/etc/apt/sources.list.d/dotcloud.list') }
end

package "lxc-docker-#{node['deis']['docker']['version']}" do
  not_if { "/usr/bin/dpkg -s lxc-docker-#{node['deis']['docker']['version']}" }
end

service 'docker' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end
