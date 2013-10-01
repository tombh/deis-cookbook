#
# Cookbook Name:: deis-proxy
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'rsyslog::client'
include_recipe 'deis::nginx'

# iterate over this node's formation

formations = data_bag('deis-formations')

config_files = []  # keep track of nginx config files
formations.each do |f|
  
  formation = data_bag_item('deis-formations', f)
  
  # skip this node if it's not part of this formation
  next if ! formation['nodes'].keys.include? node.name
  # skip this node if it's not a proxy
  next if formation['nodes'][node.name]['proxy'] != true
  
  formation['apps'].each_pair do |app_id, app|

    proxy = app['proxy']

    if formation['domain'].nil?
      server_name = 'localhost'
    else
      server_name = "#{app_id}.#{formation['domain']}"
    end
    
    vars = {:server_name => server_name,
            :app => app_id,
            :port => proxy['port'],
            :backends => proxy['backends'], 
            :algorithm => proxy['algorithm'],
            :firewall => proxy['firewall']}
  
    config_file = "deis-#{app_id}"
    nginx_site config_file do
      template 'nginx-proxy.conf.erb'
      vars vars
    end
    config_files.push(config_file)
  end
  
end

# purge old nginx configs

['/etc/nginx/sites-enabled', '/etc/nginx/sites-available'].each do |dir|
  Dir.glob("#{dir}/*").each do |path|
    f = File.basename path
    next if ! f.start_with? 'deis-'
    next if config_files.include? f
    file path do
      action :delete
      notifies :restart, "service[nginx]", :delayed
    end
  end  
end
