class AddAssociationBetweenEventsAndPlayers < ActiveRecord::Migration
  def change
    create_table :events_players do |t|
      t.belongs_to :event
      t.belongs_to :player
    end
  end
end
