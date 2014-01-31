include_recipe 'rsyslog::client'

formations = data_bag('deis-formations')

services = []
active_slug_paths = []
formations.each do |f|
  
  formation = data_bag_item('deis-formations', f)

  # skip this node if it's not part of this formation
  next if ! formation['nodes'].keys.include? node.name
  # skip this node if it's not part of the runtime
  next if formation['nodes'][node.name]['runtime'] != true
  
  formation['apps'].each_pair do |app_id, app|
    
    # skip this app if there's an empty release or build
    next if app['release'] == {}
    next if app['release']['build'] == {}
    
    version = app['release']['version']
    build = app['release']['build']
    config = app['release']['config']
    image = build['image']
  
    # iterate over this application's containers by process type
    
    app['containers'].each_pair do |c_type, c_formation|
      
      c_formation.each_pair do |c_num, node_port|
      
        nodename, port = node_port.split(':')
        
        next if nodename != node.name

        # determine build command, if one exists
        if build['procfile'] != nil and build['procfile'].has_key? c_type
          command = "start #{c_type}"
        else
          command = nil
        end
        name = "#{app_id}.#{c_type}.#{c_num}"
        # define the container
        container name do
          app_name app_id
          c_type c_type
          c_num c_num
          env config
          port port
          image image
          command command
        end
        services.push("deis-#{name}")
      end
    end
  end # formations['apps'].each
end # formations.each

# 
# # purge old container services
# 
targets = []
Dir.glob("/etc/init/deis-*").each do |path|
  svc = File.basename(path, '.conf')
  next if svc.start_with? 'deis-server'
  next if svc.start_with? 'deis-worker'
  next if services.include? svc
  s = service svc do
    provider Chef::Provider::Service::Upstart
    action :nothing
  end
  f = file path do
    action :nothing
  end
  targets.push([s, f])
end

if ! targets.empty?
  Thread.abort_on_exception = true
  ruby_block "stop-services-in-parallel" do
    block do
      threads = []
      targets.each { |s, f|
        threads << Thread.new { |t| 
          s.run_action(:stop)
          f.run_action(:delete)
        }
      }
      threads.each { |t| t.join }
    end
  end
end
