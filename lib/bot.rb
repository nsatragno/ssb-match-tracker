#!/usr/bin/ruby

require 'discordrb'

require './lib/characters.rb'
require './lib/database.rb'
require './lib/model/match.rb'
require './lib/model/season.rb'

REGISTER_COMMAND = '!register'
NEW_SEASON_COMMAND = '!new_season'
CURRENT_SEASON_COMMAND = '!current_season'
END_SEASON_COMMAND = '!end_season'

bot = Discordrb::Bot.new token: ENV['BOT_TOKEN']

# Need to reload the logger after creating a bot.
Logging.load

db = Database.new

Discordrb::LOGGER.info "ssb-match-tracker loaded!"
Discordrb::LOGGER.info "invite url: #{bot.invite_url()}"

def sanitize_character(text)
  character = text.slice(1..text.size - 2).downcase
  character = ALIASES[character] || character
  CHARACTERS.find do |listed_character|
    listed_character.downcase == character.downcase
  end
end

def get_arguments(event, command_name)
  event.message.content.slice(command_name.size + 1, event.message.content.size) or ""
end

def get_error_string(errors)
  errors.map do |field, message|
    "#{field} #{message.join(',')}"
  end.join(',')
end

bot.message(start_with: REGISTER_COMMAND) do |event|
  command = get_arguments(event, REGISTER_COMMAND)
  unless command.match? /<@.+> +\(.+?\) +\d-\d +<@.+> +\(.+?\)/ and event.message.mentions.size == 2
    event << 'Bad message format, try something like `!register @Kairos (Lucas) 0-3 @eriNa_ (Rosalina & Luma)`'
    next
  end

  left_user = event.message.mentions[0]
  right_user = event.message.mentions[1]

  characters = command.scan(/\(.+?\)/)
  left_character = sanitize_character(characters[0])
  unless left_character
    event << "Unrecognized character #{characters[0]}"
    next
  end
  right_character = sanitize_character(characters[1])
  unless right_character
    event << "Unrecognized character #{characters[1]}"
    next
  end

  Discordrb::LOGGER.good "Registered new match"
  event << "Match registered: #{left_user.username} (#{left_character}) vs #{right_user.username} (#{right_character})"
end

bot.message(start_with: NEW_SEASON_COMMAND) do |event|
  name = get_arguments(event, NEW_SEASON_COMMAND).strip
  if name.empty?
    event << "The `#{NEW_SEASON_COMMAND}` command requires a name, try `!new_season Amazing Season`"
    next
  end

  previous_season = Season.current
  if previous_season
    event << "There is a season in progress (#{previous_season.name})"
    event << "Finish that season before starting a new one (`#{END_SEASON_COMMAND}`)"
    next
  end

  season = Season.new name: name, from: Time.now
  unless season.save
    Discordrb::LOGGER.warn "Could not save season: #{season.errors.messages}"
    event << "Sorry, I could not save the season: #{get_error_string(season.errors.messages)}"
    next
  end

  Discordrb::LOGGER.good "Created new season: #{season}"
  event << "Season #{name} created! Good luck everyone! ^_^"
end

bot.message(start_with: END_SEASON_COMMAND) do |event|
  season = Season.current
  unless season
    event << "No current season in progress"
    next
  end
  season.end!
  unless season.save
    Discordrb::LOGGER.warn "Could not end season: #{season.errors.messages}"
    event << "Sorry, I could not end the season: #{get_error_string(season.errors.messages)}"
    next
  end
  event << "Season #{season.name} ended!"
end

bot.message(start_with: CURRENT_SEASON_COMMAND) do |event|
  season = Season.current
  unless season
    event << "No current season in progress"
    next
  end
  event << "Season name: #{season.name}"
  event << "Matches: #{season.matches.size}"
  event << "Started: #{season.from}"
end

bot.run
