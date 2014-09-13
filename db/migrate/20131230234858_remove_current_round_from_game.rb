class RemoveCurrentRoundFromGame < ActiveRecord::Migration
  def change
    remove_column :games, :current_round_id, :integer
  end
end
