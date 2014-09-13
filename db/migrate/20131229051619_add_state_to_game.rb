class AddStateToGame < ActiveRecord::Migration
  def change
    add_column :games, :state, :integer
  end
end
