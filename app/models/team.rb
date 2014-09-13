class Team < ActiveRecord::Base
  belongs_to :round
  has_and_belongs_to_many :players
  has_many :team_votes

  def self.collection_to_json(teams)
    teams.collect do |team|
      team.to_json
    end
  end

  def to_json
    {
      players: Player.collection_to_json(self.players),
      votes: TeamVote.collection_to_json(self.team_votes)
    }
  end
end
