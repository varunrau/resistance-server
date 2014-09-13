class Round < ActiveRecord::Base
  belongs_to :game
  belongs_to :leader, class_name: "Player", foreign_key: :leader_id
  has_many :votes
  has_many :teams

  def new_team(player_ids)
    if self.num_mission_players == player_ids.size
      Team.create round_id: self.id, player_ids: player_ids
    end
  end

  def create_team_vote(vote, current_player)
    TeamVote.create round_id: self.id, player_id: current_player.id, vote: vote, vote_round: vote_round_number, team_id: self.teams.last.id
  end

  def create_mission_vote(vote, current_player)
    MissionVote.create round_id: self.id, player_id: current_player.id, vote: vote, vote_round: vote_round_number
    if vote == Vote::Votes::PASS
      self.num_approve = self.num_approve + 1
    elsif vote == Vote::Votes::FAIL
      self.num_reject = self.num_reject + 1
    end
  end

  def process_team_votes
    num_accepted > num_rejected
  end

  def leader
    self.game.leader
  end

  def next_leader
    players = self.game.players
    last_turn = players.last.turn
    turn = players.first.turn
    players[1..-1].each do |player|
      temp = player.turn
      player.turn = turn
      player.save
      turn = temp
    end
    players.first.turn = last_turn
    players.first.save
  end

  def vote_round_number
    self.teams.length
  end

  def process_mission_votes
    if mission_succeeded?
      self.state = Vote::Votes::PASS
      self.game.num_missions_passed = self.game.num_missions_passed + 1
    else
      self.state = Vote::Votes::FAIL
      self.game.num_missions_failed = self.game.num_missions_failed + 1
    end
    self.game.save
    self.save
  end

  def mission_players
    self.teams.last.players
  end

  def mission_succeeded?
    self.game.is_double_fail_round? && num_failed <= 1 || !self.game.is_double_fail_round? && num_failed == 0
  end

  def has_team_votes?
    self.game.players.size == TeamVote.where(round_id: self.id, vote_round: vote_round_number).length
  end

  def mission_votes
    MissionVote.where(round_id: self.id)
  end

  def mission_completed?
    MissionVote.where(round_id: self.id).length == self.num_mission_players
  end

  def num_failed
    MissionVote.where(round_id: self.id, vote: Vote::Votes::FAIL).length
  end

  def num_rejected
    TeamVote.where(round_id: self.id, vote: Vote::Votes::FAIL, vote_round: vote_round_number).length
  end

  def num_passed
    MissionVote.where(round_id: self.id, vote: Vote::Votes::PASS).length
  end

  def num_accepted
    TeamVote.where(round_id: self.id, vote: Vote::Votes::PASS, vote_round: vote_round_number).length
  end

  def self.collection_to_json(rounds)
    rounds.collect do |round|
      round.to_json
    end
  end

  def status
    case self.game.state
    when Game::States::LEADER
      "Waiting for #{self.leader.name} to select a team"
    when Game::States::TEAM_VOTE
      "Waiting for everyone to vote on the team"
    when Game::States::MISSION_VOTE
      "Waiting for players to return from the mission"
    end
  end

  def to_json
    case self.game.state
    when Game::States::LEADER
      {
        leader: self.leader.to_json,
        vote_round_number: self.vote_round_number,
        teams: Team.collection_to_json(self.teams),
        num_mission_players: num_mission_players,
        status: status
      }
    when Game::States::TEAM_VOTE
      {
        leader: self.leader.to_json,
        vote_round_number: self.vote_round_number,
        teams: Team.collection_to_json(self.teams),
        team: self.teams.last.to_json,
        num_mission_players: num_mission_players,
        status: status
      }
    when Game::States::MISSION_VOTE
      {
        leader: self.leader.to_json,
        teams: Team.collection_to_json(self.teams),
        mission_players: Player.collection_to_json(mission_players),
        num_mission_players: num_mission_players,
        mission_votes: mission_votes,
        status: status
      }
    end
  end
end
