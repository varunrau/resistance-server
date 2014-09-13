class AddLadyOfTheLakeIdToGame < ActiveRecord::Migration
  def change
    add_column :games, :lol_id, :integer
  end
end
