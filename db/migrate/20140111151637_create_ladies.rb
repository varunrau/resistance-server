class CreateLadies < ActiveRecord::Migration
  def change
    create_table :ladies do |t|
      t.integer :game_id
      t.integer :player_id

      t.timestamps
    end
  end
end
