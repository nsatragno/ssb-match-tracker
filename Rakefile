require 'dotenv'

require './db/schema.rb'
require './lib/logging.rb'

Dotenv.load
Logging.load
Database.load

task :run do
  require './lib/bot.rb'
end

namespace :database do
  task :create do
    CreateSchema.migrate(:up) end

  task :destroy do
    Database.drop
  end

  task :recreate do
    Rake::Task["database:destroy"].invoke()
    Rake::Task["database:create"].invoke()
  end
end
