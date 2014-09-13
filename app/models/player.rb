class Player < ActiveRecord::Base
  belongs_to :game
  has_and_belongs_to_many :events
  belongs_to :user
  has_and_belongs_to_many :teams
  has_many :votes
  has_one :lady

  def name
    self.user.name || self.user.email || "dummy name"
  end

  def self.collection_to_json(players)
    players.collect do |player|
      player.to_json
    end
  end

  def to_json
    {
      name: name,
      position: position,
      loyalty: loyalty,
      user: self.user.to_json,
      id: self.id,
      team_votes: TeamVote.collection_to_json(TeamVote.where(player_id: self.id)),
      mission_votes: MissionVote.collection_to_json(MissionVote.where(player_id: self.id))
    }
  end
end
