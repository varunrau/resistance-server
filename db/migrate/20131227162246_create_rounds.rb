class CreateRounds < ActiveRecord::Migration
  def change
    create_table :rounds do |t|
      t.integer :leader_id
      t.integer :num_approve
      t.integer :num_players
      t.integer :num_pass
      t.integer :game_id

      t.timestamps
    end
  end
end
