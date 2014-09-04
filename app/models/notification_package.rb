class NotificationPackage < Package

  attr_accessor :device_id, :property_id, :value

  def flags()
    Package::NOTIFICATION_FLAG
  end

  def print()
    super
    puts "device_id: #{device_id}"
    puts "property_id: #{property_id}"
    puts "value: #{value}"
  end

  def get_data()
    str = [device_id, property_id, value].pack("CCC")
    str << "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" # 10 bytes
    str
  end

  def read_data(str)
    self.device_id, self.property_id, self.value = str.slice(0,3).unpack("CCC")
  end

end