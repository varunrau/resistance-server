class AddCurrentRoundIdToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :current_round_id, :integer
  end
end
