include_recipe 'deis::docker'

username = node.deis.username
group = node.deis.group
home = node.deis.dir

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
  code 'make'
  not_if "docker images | grep #{image}"
end

template '/usr/local/bin/deis-buildstep-hook' do
  source 'buildstep-hook.erb'
  mode 0755
  variables({
    :buildstep_dir => build_dir,
    :slug_dir => node.deis.build.slug_dir,
    :controller_dir => node.deis.controller.dir,
  })
end

