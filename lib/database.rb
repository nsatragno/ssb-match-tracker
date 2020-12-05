require 'active_record'

class Database
  def self.db_config
    db_config_file = File.open('./config/database.yml')
    YAML::load(db_config_file)[ENV['ENVIRONMENT']]
  end

  def self.load
    config = db_config
    puts "Database environment: #{ENV['ENVIRONMENT']}"
    puts "Loading database with config: #{config}"
    ActiveRecord::Base.establish_connection(config)
  end

  def self.drop
    path = db_config['database']
    File.delete(path) if File.exist? path
  end
end
