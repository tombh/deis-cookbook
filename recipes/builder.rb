
if node.deis.builder.packs != nil
  directory node.deis.builder.packs do
    user node.deis.username
    group node.deis.group
    mode 0755
  end
end

docker_image node.deis.builder.repository do
  repository node.deis.builder.repository
  tag node.deis.builder.tag
  action node.deis.autoupgrade ? :pull : :pull_if_missing
  cmd_timeout node.deis.builder.image_timeout
end

docker_container node.deis.builder.container do
  container_name node.deis.builder.container
  detach true
  privileged true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=22"]
  image "#{node.deis.builder.repository}:#{node.deis.builder.tag}"
  port "#{node.deis.builder.port}:22"
  volume VolumeHelper.builder(node)
  cmd_timeout 600
end

# synchronize buildpacks to use during slugbuilder execution
if node.deis.builder.packs != nil

  buildpacks = {
   'heroku-buildpack-java' => ['https://github.com/heroku/heroku-buildpack-java.git', 'master'],
   'heroku-buildpack-ruby' => ['https://github.com/heroku/heroku-buildpack-ruby.git', 'master'],
   'heroku-buildpack-python' => ['https://github.com/heroku/heroku-buildpack-python.git', 'master'],
   'heroku-buildpack-nodejs' => ['https://github.com/gabrtv/heroku-buildpack-nodejs', 'master'],
   'heroku-buildpack-play' => ['https://github.com/heroku/heroku-buildpack-play.git', 'master'],
   'heroku-buildpack-php' => ['https://github.com/CHH/heroku-buildpack-php.git', 'master'],
   'heroku-buildpack-clojure' => ['https://github.com/heroku/heroku-buildpack-clojure.git', 'master'],
   'heroku-buildpack-go' => ['https://github.com/kr/heroku-buildpack-go.git', 'master'],
   'heroku-buildpack-scala' => ['https://github.com/heroku/heroku-buildpack-scala', 'master'],
   'heroku-buildpack-dart' => ['https://github.com/igrigorik/heroku-buildpack-dart.git', 'master'],
   'heroku-buildpack-perl' => ['https://github.com/miyagawa/heroku-buildpack-perl.git', 'carton'],
  }

  buildpacks.each_pair { |path, repo|
    url, rev = repo
    git "#{node.deis.builder.packs}/#{path}" do
      user node.deis.username
      group node.deis.group
      repository url
      revision rev
      action :sync
    end
  }

end

ruby_block 'wait-for-builder' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/builder/host', seconds=300)
  end
end
