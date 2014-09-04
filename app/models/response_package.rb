class ResponsePackage < Package

  attr_accessor :result, :value

  def flags()
    Package::RESPONSE_FLAG
  end

  def print()
    super
    puts "result: #{result}"
  end

  def get_data()
    str = [result].pack("C")
    str << "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" # 12 bytes
    str
  end

  def read_data(str)
    self.result, self.value = str.slice(0,2).unpack("CC")
  end

end