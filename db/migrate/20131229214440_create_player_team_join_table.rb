class CreatePlayerTeamJoinTable < ActiveRecord::Migration
  def change
    create_table :players_teams, id: false do |t|
      t.integer :player_id
      t.integer :team_id
    end
  end
end
