class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.integer :spy_games
      t.integer :total_games
      t.integer :games_won

      t.timestamps
    end
  end
end
