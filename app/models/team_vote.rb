class TeamVote < Vote
  belongs_to :team
  belongs_to :player
  belongs_to :round

  def visible?
    self.round.vote_round_number > self.vote_round
  end

  def self.collection_to_json(teams)
    teams.collect do |team|
      team.to_json
    end
  end

  def to_json
    {
      vote: self.vote,
      public: visible?,
      id: self.id
    }
  end
end
