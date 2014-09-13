class AddLastHolderToLady < ActiveRecord::Migration
  def change
    add_column :ladies, :last_holder_id, :integer
  end
end
