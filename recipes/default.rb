#
# Cookbook Name:: deis
# Recipe:: default
#
# Copyright 2013, OpDemand LLC
#

include_recipe 'docker'


# always install these packages

package 'fail2ban'
package 'git'
package 'make'

# set public ip

if node.deis.public_ip == nil
    log "Public IP attribute not provided, falling back to 127.0.0.1..." do
    level :warn
  end
  node.default.deis.public_ip = '127.0.0.1'
end

# install etcd bindings

chef_gem 'etcd'

# home_dir = node.deis.dir
# username = node.deis.username
# 
# # create deis user with ssh access, auth keys
# # and the ability to run 'sudo chef-client'
# 
# user username do
  # system true
  # uid 324 # "reserved" for deis
  # shell '/bin/bash'
  # comment 'deis system account'
  # home home_dir
  # supports :manage_home => true
  # action :create
# end
# 
# directory home_dir do
  # user username
  # group username
  # mode 0755
# end
# 
# sudo username do
  # user  username
  # nopasswd  true
  # commands ['/usr/bin/chef-client']
# end
# 
# # create a log directory writeable by the deis user
# 
# directory node.deis.log_dir do
  # user username
  # group group
  # mode 0755
# end
# 
# 
# 
# # install docker from the debian repository
# 
# # include_recipe 'apt'
# # 
# # apt_repository 'docker' do
  # # key node['deis']['docker']['key_url']
  # # uri node['deis']['docker']['deb_url']
  # # distribution 'docker'
  # # components ['main']
# # end
# # 
# # package "lxc-docker-#{node['deis']['docker']['version']}"
# # 
# # service 'docker' do
  # # provider Chef::Provider::Service::Upstart
  # # supports :status => true, :restart => true, :reload => true
  # # action [ :enable, :start ]
# # end
