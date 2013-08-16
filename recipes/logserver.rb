include_recipe 'rsyslog::server'

template "/etc/rsyslog.d/34-deis-controller.conf" do
  source "rsyslog-controller.conf.erb"
  backup false
  variables(
    :log_dir => node['rsyslog']['log_dir'],
    :per_host_dir => node['rsyslog']['per_host_dir']
  )
  mode 0644
  notifies :restart, "service[#{node['rsyslog']['service_name']}]"
end
