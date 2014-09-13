class AddEventIdToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :event_id, :integer
  end
end
