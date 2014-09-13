class AddNumRejectAndNumFailedToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :num_reject, :integer
    add_column :rounds, :num_failed, :integer
  end
end
