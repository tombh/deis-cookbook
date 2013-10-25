#
# Cookbook Name:: gitosis
# Recipe:: default
#
# Copyright 2013, deis
#
# All rights reserved - Do Not Redistribute
#

gitosis_dir = node.deis.gitosis.dir
gitosis_checkout = "#{gitosis_dir}/checkout"
gitosis_admin_repo = "#{gitosis_dir}/repositories/gitosis-admin.git"
gitosis_admin_checkout = "#{gitosis_dir}/gitosis-admin"
gitosis_key_dir = "#{gitosis_admin_checkout}/keydir"

# create git user

user 'git' do
  system true
  uid 325 # "reserved" for git
  shell '/bin/sh'
  comment 'git version control'
  home gitosis_dir
  supports :manage_home => true
  action :create
end

# create a docker group and grant it access to
# /var/run/docker.sock
group 'docker' do
  members ['git']
  action :create
  system true
end

execute 'set-docker-sock-perms' do
  command 'chgrp docker /var/run/docker.sock'
  not_if "ls -l /var/run/docker.sock | awk {'print $4'} | grep docker"
  action :run
end


# allow the git user to run a hook that creates
# a new build & release via local python code

sudo 'git' do
  user  'git'
  runas node.deis.username
  nopasswd  true
  commands [ node.deis.controller.dir + '/bin/pre-push-hook',
             node.deis.controller.dir + '/bin/push-hook', ]
end

# synchronize the gitosis repository

directory gitosis_dir do
  user 'git'
  group 'git'
  mode 0755
end

git gitosis_checkout do
  repository node.deis.gitosis.repository
  revision node.deis.gitosis.revision
  action :sync
end

# install gitosis

bash "gitosis-install" do
  cwd gitosis_checkout
  code "python setup.py install"
  action :nothing
  subscribes :run, "git[#{gitosis_checkout}]", :immediately
end

# initialize gitosis

bash 'gitosis-generate-ssh-key' do
  user 'git'
  group 'git'
  code "ssh-keygen -t rsa -b 2048 -N '' -f #{gitosis_dir}/.ssh/gitosis-admin -C gitosis-admin"
  not_if "test -e #{gitosis_dir}/.ssh/gitosis-admin"
end

bash 'gitosis-init' do
  code "sudo -H -u git gitosis-init < #{gitosis_dir}/.ssh/gitosis-admin.pub"
  not_if "test -e #{gitosis_dir}/gitosis-admin"
end

bash 'git-clone-gitosis-admin' do
  user 'git'
  group 'git'
  cwd gitosis_dir
  code "git clone #{gitosis_admin_repo}"
  not_if "test -e #{gitosis_admin_checkout}"
end

# use the deis-users databag to construct a directory of ssh keys:
# perms['users'][username] => [ {username}_{key1}, {username}_{key2} ]

perms = {'users' => {}, 'apps' => {}}
key_paths = []  # keep track of valid key paths for purge

data_bag('deis-users').each do |username|
  user = data_bag_item('deis-users', username)
  perms['users'][username] = []
  user['ssh_keys'].each do |key_id, key_material|
    key_name = "#{username}_#{key_id}"
    key_path = "#{gitosis_key_dir}/#{key_name}.pub"
    file key_path do
      owner 'git'
      group 'git'
      content key_material
      notifies :run, 'bash[git-commit-gitosis-admin]'
    end
    perms['users'][username].push(key_name)
    key_paths.push(key_path)
  end
end

# purge old ssh keys

Dir.glob("#{gitosis_key_dir}/*.pub").each do |f|
  next if key_paths.include? f
  next if f.sub("#{gitosis_key_dir}/", '') == 'gitosis-admin.pub'
  file f do
    action :delete
    notifies :run, 'bash[git-commit-gitosis-admin]'
  end
end

# use the deis-apps databag to build list of perms:
# perms['apps'][app_id] => [ {user1}_{key1}, {user1}_{key2}, {user2}_{key1} ]

repo_dirs = [] # keep track of valid repo dirs for purge

data_bag('deis-apps').each do |app_id|
  app = data_bag_item('deis-apps', app_id)
  perms['apps'][app_id] = []
  app['users'].each do |username, role|
    dir = "#{gitosis_dir}/repositories/#{app_id}.git"
    directory dir do
      user 'git'
      group 'git'
      mode 0750
    end
    bash "gitosis-init-bare-#{app_id}" do
      user 'git'
      group 'git'
      cwd dir
      code 'git init --bare'
      not_if "test -e #{dir}/HEAD"
    end
    perms['apps'][app_id].concat(perms['users'][username])
    repo_dirs.push(dir)
  end
end

# purge old repository directories

Dir.glob("#{gitosis_dir}/repositories/*.git").each do |d|
  next if repo_dirs.include? d
  next if d.include? 'gitosis-admin.git'
  directory d do
    action :delete
    recursive true
  end
end

# rebuild the gitosis template using a complex git workflow
# TODO: replace with a more effecient git auth backend

template "#{gitosis_admin_checkout}/gitosis.conf" do
  user 'git'
  group 'git'
  source 'gitosis.conf.erb'
  variables({
    :admins => ['gitosis-admin'],
    :apps => perms['apps'],
  })
  notifies :run, 'bash[git-commit-gitosis-admin]'
end

bash 'git-commit-gitosis-admin' do
  user 'git'
  group 'git'
  cwd gitosis_admin_checkout
  code 'git add . && git commit -a -m "auto-update via chef"'
  action :nothing
  notifies :run, 'bash[git-push-gitosis-admin]'
end

bash 'git-push-gitosis-admin' do
  user 'git'
  group 'git'
  cwd gitosis_admin_checkout
  code 'git push'
  action :nothing
  notifies :run, 'bash[gitosis-update-hook]'
end

bash 'gitosis-update-hook' do
  user 'git'
  group 'git'
  cwd gitosis_admin_repo
  code 'gitosis-run-hook post-update'
  environment 'GIT_DIR' => gitosis_admin_repo, 'HOME' => gitosis_dir
  action :nothing
end
