#
# Cookbook Name:: deis
# Recipe:: default
#
# Copyright 2013, OpDemand LLC
#

# install etcd bindings

chef_gem 'etcd'

# bind docker to all interfaces for external connectivity
node.default['docker']['bind_uri'] = 'tcp://0.0.0.0:4243'

include_recipe 'docker'

# always install these packages

package 'fail2ban'
package 'git'
package 'make'

# set public ip

if node.deis.public_ip == nil
    log "ip-discovery-warning" do
      message "\nPublic IP attribute not provided, using Ohai: #{node.ipaddress}"
      level :warn
    end
    node.default.deis.public_ip = node.ipaddress
end

home_dir = node.deis.dir
username = node.deis.username

# create deis user with ssh access, auth keys
# and the ability to run 'sudo chef-client'

user username do
  system true
  uid 324 # "reserved" for deis
  shell '/bin/bash'
  comment 'deis system account'
  home home_dir
  supports :manage_home => true
  action :create
end

directory home_dir do
  user username
  group username
  mode 0755
end

sudo username do
  user  username
  nopasswd  true
  commands ['/usr/bin/chef-client']
end

directory node.deis.log_dir do
  user 'syslog'
  group 'syslog'
  mode 0775
end
