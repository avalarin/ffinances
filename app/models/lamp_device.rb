class LampDevice < Device
    
  FLAG_TURNED_ON = 1

  def turn_on sync = false
    p = create_command_package Package::TURN_ON_COMMAND
    Hardware.send p
    if (sync)
      r = Hardware.wait_response p
      self.turned_on = (r.value == 1)
    end
  end

  def turn_off sync = false
    p = create_command_package Package::TURN_OFF_COMMAND
    Hardware.send p
    if (sync)
      r = Hardware.wait_response p
      self.turned_on = (r.value == 1)
    end
  end

  def toggle sync = false
    p = create_command_package Package::TOGGLE_COMMAND
    Hardware.send p
    if (sync)
      r = Hardware.wait_response p
      self.turned_on = (r.value == 1)
    end
  end

  def turned_on? force = false
    if (force)
      p = create_command_package Package::TURNED_ON_COMMAND
      r = Hardware.send_sync p
      self.turned_on = (r.value == 1) 
    end
    return flags && (flags & LampDevice::FLAG_TURNED_ON) != 0
  end

  def turned_on= value
    self.flags ||= 0
    if (value)
      self.flags |= LampDevice::FLAG_TURNED_ON
    else
      self.flags &= ~LampDevice::FLAG_TURNED_ON
    end
  end

end