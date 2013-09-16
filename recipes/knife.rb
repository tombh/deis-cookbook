username = node.deis.username
group = node.deis.group

knife_dir = "#{node.deis.dir}/.chef"
client_key_path = "#{knife_dir}/client.pem"
validator_key_path = "#{knife_dir}/validator.pem"

# make validator key readable by deis user

file '/etc/chef/validation.pem' do
  group group
  mode 0640
end

# copy /etc/chef config to deis user's ~/.chef

directory knife_dir do
  user username
  group group
  mode 0700
end

file client_key_path do
  user username
  group group
  mode 0600
  content File.read('/etc/chef/client.pem')
end

file validator_key_path do
  user username
  group group
  mode 0600
  content File.read('/etc/chef/validation.pem')
end

file "#{knife_dir}/knife.rb" do
  user username
  group group
  mode 0600
  content File.read('/etc/chef/client.rb')
end

