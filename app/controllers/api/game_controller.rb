class Api::GameController < ApplicationController
  skip_before_filter :authenticate_api_user!, only: [:index, :show]
  skip_before_filter :authenticate_user_with_token!, only: [:index, :show]

  def index
    games = Game.all
    render json: { games: Game.collection_to_json(games) }
  end

  def show
    game = Game.find params[:id]
    render json: { game: game.to_json }, status: 200
  end

  def create
    puts request.headers
    game = Game.create name: params[:name], num_players: params[:num_players], state: Game::States::NOT_STARTED
    # TODO Make sure the user is not already playing a game
    current_api_user.player = Player.new game_id: game.id, user_id: current_api_user.id
    game.player_ids = game.player_ids << current_api_user.player.id
    if game.save
      render json: { game: game.to_json }, status: 201
    else
      render json: { message: "Game not saved." }, status: 422
    end
  end

  def join
    game = Game.find params[:game_id]
    if game.nil?
      render json: { message: "Game not found" }, status: 404
      return
    end
    if game.is_active?
      render json: { message: "This game has already started." }, status: 404
      return
    end
    current_api_user.player = Player.create game_id: game.id, user_id: current_api_user.id
    if game.players.size >= game.num_players
      game.start
      render json: { message: "The game has started!", game: game.to_json }, status: 200
      return
    end
    render json: { player: current_api_user.player.to_json, message: "You have been added to the game." }, status: 200
  end

  def submit_team
    game = Game.find params[:game_id]
    if current_api_user.player == game.leader && game.state == Game::States::LEADER
      game.current_round.new_team params[:player_ids]
      game.state = Game::States::TEAM_VOTE
      game.save
      render json: { message: "You submitted a team!", game: game.to_json }
      # Tell Everyone that the team has been decided
      return
    end
    render json: { message: "You are not the leader." }, status: 401
  end

  def team_vote
    game = Game.find params[:game_id]
    if game.state == Game::States::TEAM_VOTE
      player_vote = params[:vote]
      if Vote::Votes.has_value?(player_vote.to_i)
        game.current_round.create_team_vote(player_vote, current_api_user.player)
        if game.current_round.has_team_votes?
          if game.current_round.process_team_votes
            game.state = Game::States::MISSION_VOTE
            game.save
            render json: { message: "The team has voted!", game: game.to_json, subtitle: "The team passed!", changed: true }, status: 201
            return
            # Tell everyone that the team has voted
          else
            game.state = Game::States::LEADER
            game.save
            game.next_leader
            render json: { message: "The team has voted!", game: game.to_json, subtitle: "The team was not passed!", changed: true }, status: 201
          end
          return
        else
          render json: { message: "You voted!", game: game.to_json, changed: true }, status: 201
          # tell everyone that the team failed
        end
        return
      end
      render json: { message: "There was an error" }, status: 500
    end
  end

  def mission_vote
    game = Game.find params[:game_id]
    # need to check if the player is on the mission
    if game.state == Game::States::MISSION_VOTE
      player_vote = params[:vote]
      game.current_round.create_mission_vote player_vote, current_api_user.player
      if game.current_round.mission_completed?
        outcome = game.current_round.mission_succeeded?
        game.current_round.process_mission_votes
        if game.over?
          game.state = Game::States::ENDED
          game.save
          render json: { message: "The game is over!", game: game.to_json, subtitle: game.winner }
        end
        game.state = Game::States::LADY_OF_THE_LAKE
        game.players.each do |player|
          player.turn = player.turn + 1
          player.save
        end
        game.save
        leader = Player.where(game_id: game.id).order(:turn)
        Round.create game_id: game.id, leader_id: leader.id, num_mission_players: game.next_mission_size, vote_round: 0
        if outcome
          # Tell everyone that the mission is over
          render json: { message: "The mission members have returned!", game: game.to_json, subtitle: "The mission succeeded!" }, status: 201
        else
          # Tell everyone that the mission is over
          render json: { message: "The mission members have returned!", game: game.to_json, subtitle: "The mission failed." }, status: 201
        end
        return
      end
      render json: { message: "You voted!", game: game.to_json }, status: 201
    end
  end

  def lady_of_the_lake
    game = Game.find params[:game_id]
    if game.state == Game::States::LADY_OF_THE_LAKE
      chosen_player = Player.find params[:chosen_player_id]
      if game.valid_lady? chosen_player
        Lady.create game_id: self.id, player_id: player.id, last_holder_id: current_api_user.id
        game.state = Game::States::LEADER
        game.save
        if chosen_player.loyalty
          render json: { message: "#{chosen_player.name} is a resistance member.", game: game.to_json, loyalty: chosen_player.loyalty }, status: 200
        else
          render json: { message: "#{chosen_player.name} is a spy.", game: game.to_json, loyalty: chosen_player.loyalty }, status: 200
        end
      else
        render json: { message: "Not a valid choice!" }, status: 300
      end
    else
      render json: { message: "You're not allowed to use that right now!" }, status: 300
    end
  end
end
