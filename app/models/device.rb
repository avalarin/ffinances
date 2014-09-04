class Device < ActiveRecord::Base
  validates :name, :hub, :device_id, presence: true

  belongs_to :hub

  def get_by_hub_and_id hid, did
    where(hub_id: hid, device_id: did).first
  end

  private

  def create_command_package command
    package = CommandPackage.new
    package.source_address = 0
    package.target_address = hub.address
    package.source_radio_address = 0
    package.target_radio_address = hub.radio_address
    package.device_id = device_id
    package.command_id = command
    package
  end

end