class MissionVote < Vote
  belongs_to :team
  belongs_to :player
  belongs_to :round

  def to_json
    {
      vote: self.vote,
      id: self.id
    }
  end

end
