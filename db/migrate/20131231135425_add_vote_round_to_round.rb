class AddVoteRoundToRound < ActiveRecord::Migration
  def change
    add_column :rounds, :vote_round, :integer
  end
end
