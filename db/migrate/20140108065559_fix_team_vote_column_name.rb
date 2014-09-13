class FixTeamVoteColumnName < ActiveRecord::Migration
  def change
    rename_column :votes, :team, :vote
  end
end
