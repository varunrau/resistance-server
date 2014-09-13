class AddTurnToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :turn, :integer
  end
end
