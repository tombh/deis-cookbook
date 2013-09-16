include_recipe 'rsyslog::client'
include_recipe 'deis::docker'

username = node.deis.username
group = node.deis.group
home = node.deis.dir

directory node.deis.runtime.dir do
  user username
  group group
  mode 0700
end

directory node.deis.runtime.slug_root do
  user username
  group group
  mode 0700
end

build_dir = node.deis.build.dir

git build_dir do
  user username
  group group
  repository node.deis.build.repository
  revision node.deis.build.revision
  action :sync
end

directory node.deis.build.slug_dir do
  user username
  group group
  mode 0777 # nginx needs write access
end

image = node.deis.build.image

bash 'create-buildstep-image' do
  cwd build_dir
  code "./build.sh ./stack #{image}"
  not_if "docker images | grep #{image}"
end

package 'curl'

formations = data_bag('deis-formations')

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
    image = app['release']['image']
    
    # pull the image if it doesn't exist already
    
    bash "pull-image-#{image}" do
      cwd node.deis.runtime.dir
      code "docker pull #{image}"
      not_if "docker images | grep #{image}"
    end
    
    # if build is specified, use special heroku-style runtime
    
    if build.has_key? 'url'
    
      slug_url = build['url']
      
      # download the slug to a tempdir
      slug_root = node.deis.runtime.slug_root
      slug_dir = "#{slug_root}/#{app_id}-#{version}"
      slug_filename = "app.tar.gz"
      slug_path = "#{slug_dir}/#{slug_filename}"
      
      bash "download-slug-#{app_id}-#{version}" do
        cwd slug_root
        code <<-EOF
          rm -rf #{slug_dir}
          mkdir -p #{slug_dir}
          cd #{slug_dir}
          curl -s #{slug_url} > #{slug_path}
          tar xfz #{slug_path}
          EOF
        not_if "test -f #{slug_path}"
      end
    else
      slug_dir = nil
    end
  
    # iterate over this application's process formation by
    # Procfile-defined type
    
    app['containers'].each_pair do |c_type, c_formation|
      
      c_formation.each_pair do |c_num, node_port|
      
        nodename, port = node_port.split(':')
        
        # if the nodename doesn't match don't enable the process
        # but still define it and leave it disabled
        if nodename == node.name
          enabled = true
        else
          enabled = false
        end
        
        # determine build command, if one exists
        if build != {}
          command = build['procfile'][c_type]
        else
          command = nil # assume command baked into docker image
        end
        
        # define the container
        container "#{c_type}.#{c_num}" do
          app_name app_id
          c_type c_type
          c_num c_num
          env config
          command command
          port port
          image image
          slug_dir slug_dir
          enable enabled
        end      
    
      end
      
      # cleanup any old containers that match this process type
      (1..100).each { |n|
        
        # skip this c_num if we already processed it
        unless c_formation.has_key?(n.to_s)
          filename = "/etc/init/#{c_type}.#{n}.conf"
          
          # see if the upstart service exists
          if File.exist?(filename) or File.exist?(filename+".old")
          
            # stop and disable it
            service "#{c_type}.#{n}" do
              provider Chef::Provider::Service::Upstart
              action [:stop, :disable]
            end
            
            # delete the service definition and any *.old files
            [ filename, "#{filename}.old"].each { |fl|
                file fl do
                  action :delete
                end
              }
            end
          end
        }
      
    end
    
  end # formations['apps'].each
  
end # formations.each

