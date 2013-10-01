define :container, :c_type => nil, :c_num => nil, :env => {}, :command => '', :port => nil, :image => nil, :slug_dir => nil, :app_name => nil do # ~FC037

  name = params[:name]

  # create upstart service definition
  template "/etc/init/#{name}.conf" do # ~FC037
    source "container.conf.erb"
    mode 0644
    variables({
      :app_name => params[:app_name],
      :image => params[:image],
      :slug_dir => params[:slug_dir],
      :env => params[:env],
      :port => params[:port],
      :command => params[:command],
      :c_type => params[:c_type],
      :c_num => params[:c_num],
    })
    # stop the service to force job definition reload
    notifies :stop, "service[#{name}]", :immediately
  end

  # define an upstart daemon as enabled or disabled
  service "#{name}" do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
  end

end
