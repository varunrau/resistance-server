class Event < ActiveRecord::Base
  belongs_to :game
  has_and_belongs_to_many :players

  def self.collection_to_json(events)
    events.collect do |event|
      event.to_json
    end
  end

  def to_json
    {
      players: Player.collection_to_json(players),
    }
  end
end
