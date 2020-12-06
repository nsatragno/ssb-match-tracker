class Season < ActiveRecord::Base
  validates :name, presence: true
  validates :from, presence: true

  has_many :matches

  def self.current
    Season.find_by to: nil
  end

  def end!
    self.to = Time.now
  end
end
