require 'json'

class Chef::Recipe::EtcdHelper

  # Get the current exit code for a container
  def self.get_exit_code key
    # This line is just a hack so I don't have to go changing any other files. If this whole
    # approach proves successful then we can change the args in wait_for_key to pass the
    # actual container name. Also it won't need to pass timeouts.
    key = key.gsub('logs', 'logger').gsub('controller', 'server')

    container = key.split('/')[1..-2].join('-')
    JSON.parse(`sudo docker inspect #{container}`)[0]['State']['ExitCode']
  end

  def self.wait_for_key(host, port, k, seconds=30)
    # inline import to avoid load-time gem requirement
    require 'etcd'
    client = Etcd.client(host: host, port: port)
    while true do
      raise Chef::Exceptions::Service if get_exit_code(k) != 0
      begin
        client.get(k)
        break # Because container successfully booted
      rescue => e
        sleep 1
      end
    end
  end

end
