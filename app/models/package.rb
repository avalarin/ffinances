class Package

  attr_accessor :id, :source_address, :target_address, :source_radio_address, :target_radio_address

  def flags()
    0
  end

  def pack()
    str = [id, flags, source_address, target_address, source_radio_address, target_radio_address].pack("vCvvvv") 
    str << get_data()
    str
  end

  def self.read(str)
    f = str.slice(2, 1).unpack('C')[0]
    if (f & Package::COMMAND_FLAG) != 0
      p = CommandPackage.new
    elsif (f & Package::RESPONSE_FLAG) != 0
      p = ResponsePackage.new
    elsif (f & Package::NOTIFICATION_FLAG) != 0
      p = NotificationPackage.new
    else
      raise 'Invalid package flags ' + str[2]
    end
    p.id, f, p.source_address, p.target_address, p.source_radio_address, p.target_radio_address = str.slice(0, 11).unpack("vCvvvv")
    p.read_data(str.slice(11, 13))
    return p
  end


  def print()
    puts ((0..23).step(1).map{ |n| "%3s" % n.to_s }).join(',')
    puts (pack().unpack('C*').map{ |n| "%3s" % n.to_s }).join(',')
    puts "id: #{id}"
    puts "flags: #{flags}"
    puts "source_address: #{source_address}"
    puts "target_address: #{target_address}"
    puts "source_radio_address: #{source_radio_address}"
    puts "target_radio_address: #{target_radio_address}"
  end

  def get_data()
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" # 13 bytes
  end

  def read_data(str)

  end

  COMMAND_FLAG = 1
  RESPONSE_FLAG = 2
  NOTIFICATION_FLAG = 4

  TURN_OFF_COMMAND = 10
  TURN_ON_COMMAND = 11
  TOGGLE_COMMAND = 12
  TURNED_ON_COMMAND = 13
end