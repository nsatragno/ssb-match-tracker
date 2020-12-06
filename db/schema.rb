require 'active_record'

require './lib/database.rb'

class CreateSchema < ActiveRecord::Migration[5.2]
  def change
    create_table :seasons do |table|
      table.string :name
      table.date :from
      table.date :to
      table.timestamps
    end

    create_table :matches do |table|
      table.belongs_to :season
      table.datetime :date
      table.timestamps
    end
  end
end
