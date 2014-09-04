class CommandPackage < Package

  attr_accessor :device_id, :command_id

  def flags()
    Package::COMMAND_FLAG
  end

  def print()
    super
    puts "device_id: #{device_id}"
    puts "command_id: #{command_id}"
  end

  def get_data()
    str = [device_id, command_id].pack("CC")
    str << "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" # 11 bytes
    str
  end

  def read_data(str)
    self.device_id, self.command_id = str.slice(0,2).unpack("CC")
  end

end