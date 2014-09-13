class Vote < ActiveRecord::Base
  belongs_to :player
  belongs_to :round

  module Votes
    FAIL = 0
    PASS = 1

    def self.has_value?(vote)
      [FAIL,PASS].include? vote
    end
  end

  def self.collection_to_json(votes)
    votes.collect do |vote|
      vote.to_json
    end
  end
end
