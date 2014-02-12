
require 'timeout'

class Chef::Recipe::EtcdHelper

  def self.wait_for_key(host, port, k, seconds=30)
    # inline import to avoid load-time gem requirement
    require 'etcd'
    client = Etcd.client(host: host, port: port)    
    begin
      Timeout::timeout(seconds) do
        while true do
          begin       
            client.get(k)
            break
          rescue => e
            sleep 1
            next
          end
        end
      end
    rescue Timeout::Error
      raise
    end
  end

end
