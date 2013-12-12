include_recipe 'deis::docker'

# create build root directory
directory node.deis.build.dir do
  user node.deis.username
  group node.deis.group
end

# checkout the slugbuilder project
git node.deis.build.builder_dir do
  user node.deis.username
  group node.deis.group
  repository node.deis.build.repository
  revision node.deis.build.revision
  action :sync
end

# create a directory to host slugs
directory node.deis.build.slug_dir do
  user node.deis.username
  group node.deis.group
  mode 0777 # nginx needs write access
end

# create docker image used to run heroku buildpacks
bash 'create-slugbuilder-image' do
  cwd node.deis.build.builder_dir
  code 'docker build -t deis/slugbuilder .'
  not_if 'docker images | grep deis/slugbuilder'
end

# write out hook called by gitosis during `git push`
template '/usr/local/bin/deis-slugbuilder-hook' do
  source 'slugbuilder-hook.erb'
  mode 0755
  variables({
    :slug_dir => node.deis.build.slug_dir,
    :controller_dir => node.deis.controller.dir,
  })
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

directory node.deis.build.pack_dir do
  user node.deis.username
  group node.deis.group
  mode 0755
end

# synchronize buildpacks to use during slugbuilder execution
buildpacks.each_pair { |path, repo|
  url, rev = repo
  git "#{node.deis.build.pack_dir}/#{path}" do
    user node.deis.username
    group node.deis.group
    repository url
    revision rev
    action :sync
  end
}
