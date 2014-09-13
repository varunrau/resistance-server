class AddLoyaltyToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :loyalty, :boolean
  end
end
