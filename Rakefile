require 'dotenv'

require './db/schema.rb'

Dotenv.load
Database.load

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
