class AddCurrentRoundIdToGame < ActiveRecord::Migration
  def change
    add_column :games, :current_round_id, :integer
  end
end
