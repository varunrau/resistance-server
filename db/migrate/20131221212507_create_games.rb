class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.boolean :active

      t.timestamps
    end
  end
end
