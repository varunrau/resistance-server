class AddFieldsToGame < ActiveRecord::Migration
  def change
    add_column :games, :num_missions_failed, :integer
    add_column :games, :num_missions_passed, :integer
    add_column :games, :num_votes_failed, :integer
  end
end
