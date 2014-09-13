class AddNumMissionPlayersToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :num_mission_players, :integer
  end
end
