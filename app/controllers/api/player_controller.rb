class PlayerController < ApplicationController
  def index
    @players = Player.all
    render json: { players: @players }
  end

  def show
    @player = Player.find params[:id]
    render json: { player: @player }
  end
end
