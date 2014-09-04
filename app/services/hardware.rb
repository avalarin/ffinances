require 'socket'
require 'timeout'

class Hardware
  class << self
    
    @@pid = 0
    @@mutex = Mutex.new

    @@socket_out = UDPSocket.new
    @@socket_out.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

    @@socket_in = UDPSocket.new
    @@socket_in.bind(Settings.ethernet.listen_ip, Settings.ethernet.listen_port)
    
    @@responses = { }
    @@waiters = { }

    Thread.new do 
      loop do
        begin
          data, sender = @@socket_in.recvfrom(24)
          package = Package.read data
          case package
            when CommandPackage
            when ResponsePackage
              puts "receive #{package.id}"
              @@responses[package.id] = package
              package_waiters = @@waiters[package.id]
              if (package_waiters && package_waiters.size > 0) 
                package_waiters.each do |block|
                  block.call(package)
                end
                package_waiters = []
              end
            when NotificationPackage
              dev = Device.includes(:hub).where( hubs: { address: package.source_address }, device_id: package.device_id ).first
              if dev
                if (package.property_id = 0) 
                  dev.turned_on = (package.value == 1)
                  dev.save!
                end
              end
          end 
        rescue Exception => e
          p e 
        end
      end
    end

    def send_sync package
      send package
      wait_response package
    end

    def send package 
      @@mutex.synchronize do
        @@pid += 1
        package.id = @@pid
        @@socket_out.send(package.pack(), 0, Settings.ethernet.remote_ip, Settings.ethernet.remote_port)
        puts "send #{@@pid}"
        return @@pid
      end
    end

    def on_response p, &block
      pid = p.id
      package_waiters = @@waiters[pid]
      unless package_waiters
        package_waiters = [ block ]
        @@waiters[pid] = package_waiters
      else
        package_waiters.push block
      end
    end

    def wait_response package
      Timeout.timeout(10) do
        loop do
          response = get_response package
          return response if response
          sleep(0.20)
        end
      end
    end

    def get_response package
      return @@responses[package.id]
    end

    def responses
      return @@responses
    end

    def test
      lamps = Device.where({hub_id: 1})
      loop do
        lamps.each do |lamp|
          lamp.turn_on
          sleep 0.5
          lamp.turn_off
          sleep 0.5
        end
      end
    end

  end
end