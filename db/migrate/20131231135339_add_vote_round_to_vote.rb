class AddVoteRoundToVote < ActiveRecord::Migration
  def change
    add_column :votes, :vote_round, :integer
  end
end
