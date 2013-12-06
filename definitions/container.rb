define :container, :c_type => nil, :c_num => nil, :env => {}, :port => nil, :image => nil, :slug_dir => nil, :app_name => nil do # ~FC037

  service_name = "deis-#{params[:name]}"
  
  # create upstart service definition
  template "/etc/init/#{service_name}.conf" do # ~FC037
    source "container.conf.erb"
    mode 0644
    variables({
      :app_name => params[:app_name],
      :name => params[:name],
      :image => params[:image],
      :slug_dir => params[:slug_dir],
      :env => params[:env],
      :port => params[:port],
      :c_type => params[:c_type],
      :c_num => params[:c_num],
    })
    # stop the service to force job definition reload
    notifies :stop, "service[#{service_name}]", :immediately
  end

  # define an upstart daemon as enabled or disabled
  service "#{service_name}" do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
  end

end
