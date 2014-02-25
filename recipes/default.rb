#
# Cookbook Name:: deis
# Recipe:: default
#
# Copyright 2014, OpDemand LLC
#

# force macaddr version, see https://github.com/opdemand/deis/issues/552
chef_gem 'macaddr' do
  action :remove
  not_if '/opt/chef/embedded/bin/gem list macaddr | grep "(1.6.1)"'
end
chef_gem 'macaddr' do
  version '1.6.1'
  action :install
end

# install etcd bindings
chef_gem 'etcd'

# bind docker to all interfaces for external connectivity
node.default['docker']['bind_uri'] = 'tcp://0.0.0.0:4243'
# hardcode specific docker version
node.default['docker']['version'] = '0.8.0'
# install docker through chef-docker
include_recipe 'docker'

# In a Vagrant environment most containers have bind mount volumes to the shared /vagrant folder.
# This folder isn't mounted by vagrant until the end of the boot process which means that if the
# docker daemon starts when it normally does (start on runlevel [2345]) then the containers won't
# boot properly. To working around this in a way that doesn't mean maintaining a custom docker recipe
# we just use sed to replace the 'start on' stanza.
if node.deis.dev.mode == true
  bash "patch_docker_upstart_start_event" do
   user "root"
   code <<-EOF
      sed -i '/start on.*/c\\start on filesystem and vagrant-mounted and started lxc-net' /etc/init/docker.conf
   EOF
   not_if "grep -q vagrant-mounted /etc/init/docker.conf"
 end
end

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
