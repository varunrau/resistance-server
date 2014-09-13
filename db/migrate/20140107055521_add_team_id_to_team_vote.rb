class AddTeamIdToTeamVote < ActiveRecord::Migration
  def change
    add_column :votes, :team_id, :integer
  end
end
