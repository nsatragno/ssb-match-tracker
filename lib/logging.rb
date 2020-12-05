require 'discordrb'

class Logging
  def self.load
    Discordrb::LOGGER.mode = :normal
    Discordrb::LOGGER.fancy = true
  end
end
