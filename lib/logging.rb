require 'discordrb'

class Logging
  def self.load
    Discordrb::LOGGER.mode = :verbose
    Discordrb::LOGGER.fancy = true
  end
end
