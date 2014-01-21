
require 'timeout'
require 'socket'

class Chef::Recipe::Connect

  def self.wait_tcp(ip, port, seconds=5)
    begin
      Timeout::timeout(seconds) do
        while true do
          begin
            Chef::Log.debug("Trying connection to #{ip}:#{port}!")
            TCPSocket.new(ip, port).close
            Chef::Log.debug("Connected to #{ip}:#{port}!")
            break
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
            Chef::Log.debug("Connection error #{e}:")
            sleep 1
            next
          end
        end
      end
    rescue Timeout::Error => e
      raise  
    end
  end
    
end
