
directory node.deis.builder.packs do
  user node.deis.username
  group node.deis.group
  mode 0755
end

docker_container node.deis.builder.container do
  container_name node.deis.builder.container
  detach true
  privileged true
  env ["ETCD=#{node.deis.public_ip}:#{node.deis.etcd.port}",
       "HOST=#{node.deis.public_ip}",
       "PORT=22"]
  image node.deis.builder.image
  init_type false
  port "#{node.deis.builder.port}:22"
  # bind mount /app if we're running out of vagrant
  volume ["#{node.deis.builder.packs}:/tmp/buildpacks", 
          File.exist?('/vagrant/images/builder') ? "/vagrant/images/builder:/app" : nil ]
  cmd_timeout 600 # image takes a while to download
end

# custom buildpacks repositories and revisions
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

# synchronize buildpacks to use during slugbuilder execution
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

ruby_block 'wait-for-builder' do
  block do
    EtcdHelper.wait_for_key(node.deis.public_ip, node.deis.etcd.port,
                            '/deis/builder/host', sleep=120)
  end
end