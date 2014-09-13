class AddFirstPlayerIdToGame < ActiveRecord::Migration
  def change
    add_column :games, :first_player_id, :integer
  end
end
