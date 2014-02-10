#
# Cookbook Name:: deis
# Recipe:: default
#
# Copyright 2014, OpDemand LLC
#

# install etcd bindings
chef_gem 'etcd'

# bind docker to all interfaces for external connectivity
node.default['docker']['bind_uri'] = 'tcp://0.0.0.0:4243'
# hardcode specific docker version
node.default['docker']['version'] = '0.8.0'
# install docker through chef-docker
include_recipe 'docker'

# install required packages
package 'fail2ban'
package 'git'
package 'make'

# set public ip via Ohai if not defined
if node.deis.public_ip == nil
  node.default.deis.public_ip = node.ipaddress
end

# create deis user with ssh access, auth keys
# and the ability to run 'sudo chef-client'

user node.deis.username do
  system true
  uid 324 # "reserved" for deis
  shell '/bin/bash'
  comment 'deis system account'
  home node.deis.dir
  supports :manage_home => true
  action :create
end

directory node.deis.dir do
  user node.deis.username
  group node.deis.username
  mode 0755
end

sudo node.deis.username do
  user node.deis.username
  nopasswd  true
  commands ['/usr/bin/chef-client']
end

directory node.deis.log_dir do
  user 'syslog'
  group 'syslog'
  mode 0775
end
