class Game < ActiveRecord::Base
  has_many :players
  has_many :events
  has_many :rounds
  has_many :ladies
  belongs_to :first_player, class_name: "Player", foreign_key: :first_player_id

  SPY_NUMS = {
    "5" => 2,
    "6" => 2,
    "7" => 3,
    "8" => 3,
    "9" => 3,
    "10" => 4
  }

  ROLES = {
    "5" => {resistance_roles: ["Merlin"], spy_roles: ["Assassin"]},
    "6" => { resistance_roles: ["Merlin"], spy_roles: ["Assassin"] },
    "7" => { resistance_roles: ["Merlin", "Percival"], spy_roles: ["Assassin", "Morgana"] },
    "8" => { resistance_roles: ["Merlin", "Percival"], spy_roles: ["Assassin", "Morgana", "Mordred"] },
    "9" => { resistance_roles: ["Merlin", "Percival"], spy_roles: ["Assassin", "Morgana", "Mordred"] },
    "10" => { resistance_roles: ["Merlin", "Percival"], spy_roles: ["Assassin", "Morgana", "Mordred"] }
  }

  MISSION_COUNT = {
    "5" => [2, 3, 2, 3, 3],
    "6" => [2, 3, 4, 3, 4],
    "7" => [2, 3, 3, -4, 4],
    "8" => [3, 4, 4, -5, 5],
    "9" => [3, 4, 4, -5, 5],
    "10" => [3, 4, 4, -5, 5]
  }

  MIN_PLAYER_COUNT = 5

  module States
    NOT_STARTED = 0
    LEADER = 1
    TEAM_VOTE = 2
    MISSION_VOTE = 3
    LADY_OF_THE_LAKE = 4
    ENDED = 5
  end

  def start
    resistance_roles = ROLES[players.size.to_s][:resistance_roles]
    spy_roles = ROLES[players.size.to_s][:spy_roles]
    (spy_count - spy_roles.length).times do
      spy_roles = spy_roles << "Spy"
    end
    (self.players.size - spy_count - resistance_roles.length).times do
      resistance_roles = resistance_roles << "Resistance"
    end
    puts resistance_roles
    spies = players.sample spy_count
    spies.each do |spy|
      spy.update_attributes loyalty: false
      spy.position = spy_roles.sample
      spy_roles.delete spy.position
      spy.save
    end
    self.players.each do |resistance|
      unless spies.include? resistance
        resistance.update_attributes loyalty: true
        resistance.position = resistance_roles.sample
        resistance.save
        resistance_roles.slice! resistance_roles.index(resistance.position)
      end
    end
    turn_positions = (1..players.size).to_a.shuffle
    self.players.each do |player|
      player.turn = turn_positions.shift
      player.save
    end
    self.player_ids = self.player_ids.shuffle
    Lady.create game_id: self.id, player_id: self.players.last.id
    self.rounds = self.rounds << Round.create(game_id: id,
                                              num_mission_players: MISSION_COUNT[players.size.to_s][0],
                                             vote_round: 0)
    self.state = States::LEADER
    self.active = true
    self.num_missions_failed = 0
    self.num_missions_passed = 0
    self.first_player_id = self.player_ids.first
    self.save
  end

  def valid_lady?(player)
    self.ladies.each do |lady|
      if lady.player.eq? player
        return false
      end
    end
    true
  end

  def players
    Player.where(game_id: self.id).order("turn asc")
  end

  def current_lady
    self.ladies.last
  end

  def num_rounds_in_game
    MISSION_COUNT[players.size.to_s]
  end

  def current_round
    self.rounds.last
  end

  def round_number
    self.rounds.length - 1
  end

  def next_mission_size
    MISSION_COUNT[(self.players.size + 1).to_s][round_number]
  end

  def is_double_fail_round?
    MISSION_COUNT[self.players.size.to_s][round_number] < 0
  end

  def spy_count
    SPY_NUMS[players.size.to_s]
  end

  def self.collection_to_mini_json(games)
    games.collect do |game|
      game.to_mini_json
    end
  end

  def current_status
    if is_active?
      self.current_round.status
    else
      "The game has not yet started"
    end
  end

  def leader
    self.players.first
  end

  def next_leader
    self.current_round.next_leader
  end

  def to_s
    name.titleize
  end

  def is_active?
    return active
  end

  def successful_rounds
    Round.where game_id: self.id, state: Vote::Votes::PASSED
  end

  def failed_rounds
    Round.where game_id: self.id, state: Vote::Votes::FAILED
  end

  def over?
    self.rounds.length == num_rounds_in_game
  end

  def winner
    if self.state = States::ENDED
      requirement = 0
      if self.num_players % 2 != 0
        requirement = 1
      end
      if successful_rounds >= (self.num_players / 2) + requirement
        "Resistance"
      else
        "Spies"
      end
    end
  end

  def to_mini_json
    {
      name: name,
      id: id
    }
  end

  def self.collection_to_json(games)
    games.collect do |game|
      game.to_json
    end
  end

  def to_json
    json = {
      name: name,
      id: id,
      players: Player.collection_to_json(self.players),
      rounds: Round.collection_to_json(self.rounds),
      state: self.state,
      ladies: self.ladies,
      status: current_status
    }
    if current_round
      json[:leader] = current_round.leader
      json[:lady] = current_lady.to_json
      json[:first_player] = self.first_player.to_json
      return json
    end
    json
  end
end
