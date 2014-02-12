
require 'net/http'
require 'socket'
require 'timeout'

class Chef::Recipe::Connect

  def self.wait_tcp(ip, port, seconds=30)
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

  def self.wait_http(u, seconds=30)
    begin
      Timeout::timeout(seconds) do
        url = URI.parse(u)
        while true do
          Chef::Log.debug("Trying connection to #{url}")
          req = Net::HTTP::Get.new(url.to_s)
          begin
            res = Net::HTTP.start(url.host, url.port) {|http|
              http.request(req)
            }
            if res.code == '200'
              return
            end
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
            Chef::Log.debug("Connection error #{e}:")
          sleep 1
          end
        end
      end
    rescue Timeout::Error => e
      raise
    end
  end
    
end
