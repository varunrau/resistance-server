class AddStateToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :state, :integer
  end
end
